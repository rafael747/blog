---
layout: post
title: Mirror a remote Postgresql table (dblink + materialized views)
description: >
  Keep a local mirrored table of a remote PostgreSQL server.
image: /assets/img/postgres-remote-table/postgres-logo.png
noindex: true
---

It is very useful to have a local version of a production table in a local server. Among some reasons, we have:

 - No worries about messing with production data;
 - Still, having some realistic data to work with;
 - Low latency (for big tables, or heavy data types);

To achieve this, we can make use of some cool postgresql features:

 - dblink extension;
 - materialized views;
 - postgis extension (when dealing with GIS data)

With this setup, we can maintaing a local mirrored version of a remote database table. We can also refresh the data easily, to keep it updated with the remote database.

## DBLINK EXTENSION

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

## MATERIALIZED VIEWS

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

## Creating a panel

The following example creates a [Pie Chart](https://grafana.com/plugins/grafana-piechart-panel) with some statistics about the geometry field (the type of the geometry, in this case)

* * *
![](/assets/img/grafana_bbox/regular_query.png)
* * *

Unfortunately, Grafana doesn't support this kind for geometry filtering using a bbox.

## But wait, what is bbox filtering?

The following SQL example gives an overview on how to filter geometries using a bbox. You can find the right parameter for you [here](http://bboxfinder.com).

* * *
![](/assets/img/grafana_bbox/envelope_brazil.png)

* * *
Once I have a polygon with an area of interest, I can add a **where** closure to only show geometries which are inside this **bounding box** 

* * *
![](/assets/img/grafana_bbox/sql_with_bb_filter_1.png)
* * *

Now suppose we want to get some stats from a smaller region. 
Something like this:

* * *
![](/assets/img/grafana_bbox/envelope_sao_paulo.png)
* * *

We just need to change the bbox value in the where closure:

* * *
![](/assets/img/grafana_bbox/sql_with_bb_filter_2.png)
* * *

This way, only the geometries inside the polygon will be computed.

This is what a Mapserver does when a client requests a layer and inform the currently visible area of the map component.

The client usually send the bounding box in a query parameter like this:

```
https://somesite.com/wms?layers=somelayer&REQUEST=GetMap&BBOX=-52.185059,-24.447150,-43.912354,-19.269665
```

**How to achieve this feature in Grafana?**

## Dashboard Variables


These dashboard variables provide a very efficient way to filter panels using predefined values. A variable is presented as a dropdown select box at the top of the dashboard. It has a current value and a set of options. The options are the set of values you can choose from.

You can get the options by some means:

 - From a query to the database;
 - A predefined interval of values;
 - A list of datasources;
 - Some hardcoded values.

These kinds of variables are very useful for most of the cases. However, a bounding box is not something we can get using a query and selecting from a dropdown list.

**There is a way to override a variable value, no matter how the variable is defined in the first place.**

We just need to pass the variable in the query string to the dashboard URL using the following sintax:

> **&var-somevar=somevalue**
{:.lead}

## Defining a Dashboard Variable

Lets create a variable, so we can override it later.

* * *
![](/assets/img/grafana_bbox/dashboard_variables.png)
* * *

I created a single value list, with the bbox of the Brazil. This will be our default value used if no other value is passed.

Now lets tweak our query to include the defined variable:

* * *
![](/assets/img/grafana_bbox/filtered_query.png)
* * *

## Sending the bbox to the panel

Once we get our panel with a default value working:
 
* * *
![](/assets/img/grafana_bbox/panel_view.png)
This is the url: http://localhost:3000/d/NI2peTVWz/dashboard?orgId=1&var-bb=-75,-33,-30,5&panelId=15&fullscreen
{:.figure}

We can filter our panel to a smaller bbox by overriding the **var-bb** parameter:

* * *
![](/assets/img/grafana_bbox/panel_view_2.png)
This is the url: http://localhost:3000/d/NI2peTVWz/dashboard?orgId=1&var-bb=-49.592972,-20.913983,-49.174805,-20.671978&panelId=15&fullscreen
{:.figure}

* * *

Notice that the query returned less values because of the smaller region provided in the url.


A big plus in this solution is that the bounding box parameter follow the same syntax in the Grafana panel and in a mapserver wms layer:

 - Mapserver WMS layer request:

> https://othersite.com/wms?layers=otherlayer&REQUEST=GetMap&BBOX=-49.592972,-20.913983,-49.174805,-20.671978

 - Grafana Panel request:

> http://grafanahost:3000/d/NI2peTVWz/dashboard?orgId=1&panelId=15&fullscreen&var-bb=-49.592972,-20.913983,-49.174805,-20.671978


We can easily integrate embed Grafana panels to an application with a map component. This way, in order to show statistics for particular regions, we can make use of the already present bbox parameter of the WMS layer.


* * *

Big Thanks to [Lucija Raženj](https://q-more.github.io/qmore/) for helping me with dashboard variables in Grafana :)

