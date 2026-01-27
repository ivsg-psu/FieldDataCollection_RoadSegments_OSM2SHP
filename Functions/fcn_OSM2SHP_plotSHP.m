roads = readgeotable("PA_roads.shp");

figure;
geoplot(roads, 'LineWidth', 1)
title("OSM Highways PA")
