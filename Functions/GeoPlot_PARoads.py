# pip install pyrosm geopandas matplotlib pyproj # (Run this command in console to install these libraries)

# Note: I used PyCharm to run my Python code.

# # IMPORTANT: Shapefile is a *set* of files, not just one

from pyrosm import OSM
# import matplotlib.pyplot as plt

# Location of your OSM .pbf file (You can find this at: OneDrive/IVSG/GitHubMirror/OSM2SHP_data)
pbf_path = "/Users/aneeshbatchu/Documents/IVSG/Aneesh/PAroads/pennsylvania-260125.osm.pbf"  # update to your path

# Load your OSM file: pennsylvania-260125.osm.pbf
osm = OSM(pbf_path)

# Get drivable road network (highway column already exists) - It takes about 20-30 mins to generate a shape file of all PA roads
roads = osm.get_network(network_type="driving")

# # Keep only major roads like highways
# roads = roads[roads["highway"].isin(["motorway", "trunk", "primary"])]  # Uncomment this line to only get highways

# Outputs the shape file to this location
output_path = "/Users/aneeshbatchu/Documents/IVSG/Aneesh/PARoads/PA_ALL_roads"  # update the location to save your shape file
roads.to_file(output_path + ".shp")

# # Plotting in Python (Not Recommended)
# ax = roads.plot(figsize=(10, 10), linewidth=0.4)
# ax.set_title("Pennsylvania Major Roads (OSM)")
# plt.show()


# # Comment above code and run this code for generating a shape file of a specific location (using

# from pyrosm import OSM
# import matplotlib.pyplot as plt
#
# pbf_path = "/Users/aneeshbatchu/Documents/IVSG/Aneesh/PARoads/pennsylvania-260125.osm.pbf"
#
# # Very small bounding box around State College
# # Format: [west, south, east, north]
# bbox = [-77.95, 40.77, -77.80, 40.85]
#
# osm = OSM(pbf_path, bounding_box=bbox)
#
# roads = osm.get_network(network_type="driving")
# # roads.to_file("state_college_roads.gpkg", driver="GPKG")
#
# # IMPORTANT: Shapefile is a *set* of files, not just one
# output_path = "/Users/aneeshbatchu/Documents/IVSG/Aneesh/PARoads/state_college_roads"   # Update your output path
# roads.to_file(output_path + ".shp")
#
# # Plotting (Not Recommended)
# ax = roads.plot(figsize=(6, 6), linewidth=1.0)
# ax.set_title("OSM Roads – State College Test Region")
# plt.show()
#


