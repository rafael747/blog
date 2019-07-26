---
layout: post
title: Share a local port using localhost.run
description: >
  Create a public url for a local port, no worries about firewall, NAT, etc..
image: /assets/img/postgres-remote-table/postgres-logo.png
noindex: true
---

Sometimes it is very useful to share a local port in your computer to let other person 

## localhost.run

It is a free service that allow a user to share a localhost port using a public available url.

For example:



This allow a user to access a service running in a port in your computer on port 80


link to the project:

## How does it works

It uses the SSH protocol to forward the requests made the the public url to the configured local port.

SSH OPTION -R

HOW DOES IT WORK...

This way, then doing this:

  ssh localhost.run -R 80:localhost:80

IMG TERMINAL

Anyone with access to the public url will get the requests forwarded to the local port


To share other local port you can change **localhost:80** to **localhost:4000**

  ssh localhost.run -R 80:localhost:4000

> this way, conections will be forwarded to port 4000 on localhost

You can even allow a connection to another host on your network, not worring about firewall or NAT/port forwarding

  ssh localhost.run -R 80:otherhost:80

To generate a custom public url you can use a different username on the ssh connection:

 
  ssh somecustomname@localhost.run -R 80:localhost:4000

This way, the generated url will be **somecustomname.localhost.run** (if no one is using this username)

## Use Cases
    

# Share a service listening on 127.0.0.1

I already used this service to access some unpublished pages of this blog on my phone

Since the **bundle exec jekyll serve** command will listen on **127.0.0.1:4000**

I could'n access it from my phone, even on the same network.

> I can change jekyll configuration to listen on 0.0.0.0, but I still need to be in the same network. (if my phone is using mobile data it won't work)

* * *

# Testing a webhook in a local environment 

When testing a webhook, it is useful to get the requests on you local machine

This can be a bit hard when dealing in a closed network, with private IP ranges.


You can view the requests made the following way

 ssh

 nc -l

 nginx access.log

 project running..

# Share a local file

Another use case is file sharing

With the default nginx instalation you can put some files on the webserver **www** folder:


 example....


 ssh command

Now we can access these file anywhere:


 img 


########################



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


