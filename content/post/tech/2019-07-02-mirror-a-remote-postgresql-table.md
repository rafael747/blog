---
date: '2019-07-02'
title: Mirror a remote Postgresql table (dblink + materialized view)
image: /img/postgres-remote-table/postgres-logo.png
url: '/tech/:slug'
categories: ['tech']
---

It is very useful to have a copy of a production table in a local server.

<!--more-->

Among some reasons, we have:

 - No worries about messing with production data;
 - Still, having some realistic data to work with;
 - Low latency (for big tables, or heavy data types).

To achieve this, we can make use of some PostgreSQL features:

 - dblink extension;
 - materialized views;
 - postgis extension (when dealing with GIS data).

With this setup, we can maintain a local mirrored version of a remote database table. We can also refresh the data easily, to keep it updated with the remote database.

## DBLINK Extension

**dblink** is a module that supports connections to other PostgreSQL databases from within a database session.

Enable the extension with:

```sql
CREATE EXTENSION dblink;
```

dblink executes a query (usually a SELECT, but it can be any SQL statement that returns rows) in a remote database.

```sql
SELECT * FROM 
  dblink('dbname=otherdb hostaddr=otherhost user=otheruser password=otherpass options=-csearch_path=',
         'select proname, prosrc from pg_proc')
AS t1(proname name, prosrc text);
```
More info about the dblink extension [here](https://www.postgresql.org/docs/10/contrib-dblink-function.html).

## Materialized Views

Materialized views in PostgreSQL use the rule system like views do, but persist the results in a table-like form. The main differences between:

```sql
CREATE MATERIALIZED VIEW mymatview AS SELECT * FROM mytab;
```

and:

```sql
CREATE TABLE mymatview AS SELECT * FROM mytab;
```

are that the materialized view cannot subsequently be directly updated and that the query used to create the materialized view is stored in exactly the same way that a view's query is stored, so that fresh data can be generated for the materialized view with:

```sql
REFRESH MATERIALIZED VIEW mymatview;
```

More info about materialized views [here](https://www.postgresql.org/docs/10/rules-materializedviews.html).


## Create the mirrored table

The benefit of a materialized view with the dblink extesion allow us to have a copy of a remote table.

The following command creates a **copy** of a remote table as a **materialized view**:

```sql

--DROP MATERIALIZED IEW IF EXISTS mv_users;

CREATE MATERIALIZED VIEW mv_users AS 
	SELECT
		t1.id, t1.name, t1.email, t1.password
	FROM dblink('
		dbname=somedb hostaddr=somehost user=someuser password=somepass options=-csearch_path='::text,
		'SELECT id, name, email, password FROM users'::text) 
	t1(id integer, name character varying(255), email character varying(255), password character varying(255))
WITH DATA;
```

In order to refresh a materialized view [concurrently](https://www.postgresql.org/docs/10/sql-refreshmaterializedview.html), we must create an index on it:

```sql

CREATE UNIQUE INDEX index_mv_users
  ON mv_users
  USING btree
  (id);

```

We can refresh this materialized view in order to get updated data from the remote server:

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_users WITH DATA;
```

## Materialized Views can not be directly updated


This solution works very well to read only tables in a local server.

If we ever need to update this mirrored table (update, insert, delete) you can:


### **Create a copy of the materialized view, as a table**

This first approach create copy of the data, as another table:

```sql
CREATE TABLE users AS TABLE mv_users;
```

This way, you can update the created table as needed. The only drawback is that this table will only contain the data, no **PRIMARY KEYS, SEQUENCES, CONSTRAINTS or INDEXES**

> You can create them later, if you want.

* * *

### **Create an identical table, and use the view to fill it with data**

This approach requires a bit more of setup, but it will make the update process easier.
You can also use a normal VIEW since you will only use it to fill the data in a brand new table.

  - Create a local table with the same schema:

```sql 

--DROP TABLE IF EXISTS users;

CREATE TABLE users
(
  id serial NOT NULL,
  name character varying(255) NOT NULL,
  email character varying(255) NOT NULL,
  password character varying(255) NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

OTHER CONSTRAINTS, INDEXES, ETC.. 
 
```

  - With an identical schema, you can use the materialized view to fill it with data:

```sql

INSERT INTO users (id, name, email, password)
SELECT id, name, email, password from mv_users;

```

  - Since we also selected the **id** field (serial), we need to fix the sequence: 

```sql
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users)+1);
``` 

> This will set the sequence's next value to the next available id

* * *

This way you get an identical table of the remote server.

  - You can refresh the data by TRUNCATING the table and using the view to fill it again.
  - You can also tweak the **INSERT INTO ... SELECT** query to only insert the missing rows, for example.


