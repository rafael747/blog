---
layout: post
title: Bounding Box Filtered Grafana Panels (with Postgis)
description: >
  If you can filter a panel by time, why not to use a bounding box?
image: /assets/img/grafana_bbox/regular_panel.png
noindex: true
comments: true
---

Today at work I had to create some dynamic panels in grafana for a project involving some geometry data in Postgresql (Postgis). Most of the data are polygons, with some meta data related to them.
 
Since we already use Mapserver with Postgresql for managing layers, it would be very natural to use the bounding box filtering (e.g. WMS ) to display stats for some specific region of interest.

This feature (filter a query in grafana with a bbox) along with embed panels (via iframe) would totally solve the problem. But the problem is.. how to achive such feature in grafana? 

## Creating a panel

The following example creates a [Pie Chart](https://grafana.com/plugins/grafana-piechart-panel) with some statistics about the geometry field (the type of the geometry, in this case)

![](/assets/img/grafana_bbox/regular_query.png)

Unfortunately, Grafana doesn't support this kind for geometry filtering using a bbox.

## But wait, what is this bbox filtering?

The following SQL example gives a overview of how to filter geometries using a bbox. You can find the right parameter for you [here](http://bboxfinder.com).

![](/assets/img/grafana_bbox/envelope_brazil.png)

Once I have a polygon with a area of interest, I can add a **where** clousure to only show geometries which are inside this **bounding box** 

![](/assets/img/grafana_bbox/sql_with_bb_filter_1.png)

Now supose we want to get some stats from a smaller region. 
Something like this:

![](/assets/img/grafana_bbox/envelope_sao_paulo.png)

We just need to change the bbox value in the where clousure:

![](/assets/img/grafana_bbox/sql_with_bb_filter_2.png)

This way, only the geometries inside the polygon will be computed.

This is what a Mapserver does when a client request a layer and inform the curretly visible area of the map component.

The client usually send the bounding box in a query parameter like this:

```
https://somesite.com/wms?layers=somelayer&REQUEST=GetMap&BBOX=-52.185059,-24.447150,-43.912354,-19.269665
```

**How to achive this feature in Grafana?**

## Dashboard Variables


These dashboard variables provide a very efficient way to filter panels using predefined values. A variable is presented as a dropdown select box at the top of the dashboard. It has a current value and a set of options. The options is the set of values you can choose from.

You can get the options by some means:

 - From a query to the database;
 - A predefined interval of values;
 - A list of datasources;
 - Some hardcoded values.

These kind of variables are very usefull for most of the cases. But a bounding box is not something we can get using a query and selecting from a dropdown.

**But there is a way to override a variable value, no mater how the variable is defined in the first place.**

We just need to pass the variable in the query string to the dashboard url using the following sintax:


  **&var-somevar=somevalue**

## Defining a Dashboard Variable

Let create a variable, so we can override it later.

![](/assets/img/grafana_bbox/dashboard_variables.png)

I created a single value list, with the bbox of the Brazil. This will be our default value used if no other value is passed.

Now lets tweak our query to include the defined variable:

![](/assets/img/grafana_bbox/filtered_query.png)

## Sending the bbox to the panel

Once we get our panel with a dafault value working:
 
![](/assets/img/grafana_bbox/panel_view.png)

> This is the url: http://192.168.2.53:3000/d/NI2peTVWz/dashboard?orgId=1&var-bb=-75,-33,-30,5&panelId=15&fullscreen

We can filter our panel to a smaller bbox by overriding the **var-bb** parameter:

![](/assets/img/grafana_bbox/panel_view_2.png)


> This is the url: http://192.168.2.53:3000/d/NI2peTVWz/dashboard?orgId=1&var-bb=-49.592972,-20.913983,-49.174805,-20.671978&panelId=15&fullscreen

Notice that the query returned less values, because of the smaller region provided in the url.


A big plus in this solution is that the bounding box parameter follow the same syntax in the grafana panel and in a mapserver wms layer:

 - Mapserver WMS layer request:

> https://othersite.com/wms?layers=otherlayer&REQUEST=GetMap&**BBOX=-49.592972,-20.913983,-49.174805,-20.671978**

 - Grafana Panel request:
> http://192.168.2.53:3000/d/NI2peTVWz/dashboard?orgId=1&panelId=15&fullscreen&**var-bb=-49.592972,-20.913983,-49.174805,-20.671978**


This way we can easily integrate embed grafana panels to a application with a map component in order to show statistics for particular regions in a dynamic way, making use of the already present bbox parameter of the WMS layer.


* * *

Big Thanks to [Lucija Raženj](https://q-more.github.io/qmore/) for helping me getting these results :)

