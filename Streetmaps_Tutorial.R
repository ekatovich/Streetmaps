######################################################
#Creating Streemaps with Open Street Map and ggplot2
######################################################

#Created: April 15, 2020
#By: Erik Katovich

#This R script creates black-background and watercolor 
#streetmaps of Madison, Wisconsin and Rio de Janeiro, 
#Brazil. Using Open Street Map's open access geocoded
#data, you can replicate this code to create beautiful 
#maps of almost any city. 

#You should also refer to nice mapping tutorials by
#ggplot2tor:https://ggplot2tutor.com/streetmaps/streetmaps/
#and Josh McCrain: http://joshuamccrain.com/tutorials/maps/streets_tutorial.html

#This script recreates the steps in these tutorials, and
#adds watercolor stamen tiles for a unique watercolor 
#appearance. 

#First, load required packages
library(tidyverse)
library(osmdata)
library(ggplot2)
library(sf)
library(dplyr)
library(rio)
library(geosphere)
library(foreign)
library(ggmap)
library(gridExtra)

#Before we begin, we can explore the spatial data available
#in Open Street Map (https://www.openstreetmap.org/#map=4/38.01/-95.84)
#using the available_features() command:
available_features()

#As you can see, there are many geographical features that can be mapped. 

#Next, we need to identify the coordinates of the place we want to map.
#These coordinates will come in handy in the mapping step, when we have
#to identify which part of the map to look at.

#To identify the coordinates of the place you're interested in, simply
#include them in the following command. In this case, Rio de Janeiro, Brazil:
getbb("Rio de Janeiro Brazil")
#Save the output from this command, we'll need it later when we create our map.

#Next, we need to download the geographical features (from the
#available_features() command above) we want to map. Since I want to 
#create a streetmap, I download streets. To do so, we need to pass output
#from getbb to the opq function and then to the add_osm_feature function.
#In this setup you need to specify two arguments: the key and the values.
#Here, key is the feature (highway) and values are the tags (motorway,
#primary, secondary, and tertiary). Other features have other tags 
#associated with them. Finally, we transfer this output into the osmdata_sf()
#function so that we can use it in ggplot2. 
streets <- getbb("Rio de Janeiro Brazil")%>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("motorway", "primary", 
                            "secondary", "tertiary")) %>%
  osmdata_sf()

#Next, do the same operations to download small street data
#and attach it to osmdata_sf()
small_streets <- getbb("Rio de Janeiro Brazil")%>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("residential", "living_street",
                            "unclassified",
                            "service", "footway")) %>%
  osmdata_sf()

#To create your map you may want to plot more than streets.
#The following functions illustrate how I downloaded and 
#loaded into osmdata_sf() information on rivers and forests.
river <- getbb("Rio de Janeiro Brazil")%>%
  opq()%>%
  add_osm_feature(key = "waterway", value = "river") %>%
  osmdata_sf()

water_bodies <- getbb("Rio de Janeiro Brazil")%>%
  opq()%>%
  add_osm_feature(key = "natural", value = "water") %>%
  osmdata_sf()

forest <- getbb("Rio de Janeiro Brazil")%>%
  opq()%>%
  add_osm_feature(key = "natural", value = "wood") %>%
  osmdata_sf()


##############################################################
#Now we're ready to map. Let's start by creating a very basic
#map. It's not going to look very good, but we'll 
#customize it later. 

#Add the geom_sf function to ggplot(), and
#reference the data you want to plot. I want to plot streets
#which is stored as variable streets$osm_lines. 
#I specify that I want streets to be black and I adjust size
#and alpha (transparency). Feel free to play around with these.

#In the coord_sf function, speicify the coordinates reported
#when you executed the getbb() function earlier. These are 
#the default coordinates for your map; we'll adjust them later.
#Use theme_void() to not report coordinates and coordinate 
#lines, though if you like this look, simply omit theme_void()
ggplot() +
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .4,
          alpha = .8) +
  coord_sf(xlim = c(-43.79625, -43.09908), 
           ylim = c(-23.08271, -22.74609),
           expand = FALSE) +
  theme_void()

#To add more of the features that we previously downloaded
#and attached to osmdata_sf(), simply repeat the geom_sf 
#command, always using a "+" symbol to add new functions 
#on top of the base ggplot() function. In this case,
#I still plot streets, but I add small streets and rivers.
#In this example I change the color of rivers to "blue".
ggplot() +
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .4,
          alpha = .8) +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "black",
          size = .4,
          alpha = .6) +
  geom_sf(data = river$osm_lines,
          inherit.aes = FALSE,
          color = "blue",
          size = .2,
          alpha = .5) +
  coord_sf(xlim = c(-43.79625, -43.09908), 
           ylim = c(-23.08271, -22.74609),
           expand = FALSE) +
  theme_void()


#Next, I want to change the background color to black 
#to give the map a nighttime look. To do so, I add
#a new them (using the standard ggplot "+") where 
#I define plot.backgroun = element_rect(fill = "grey1")
#In this case, I chose color code #282828, but I could choose 
#any code given here: https://www.rapidtables.com/web/color/RGB_Color.html
#or here: http://sape.inf.usi.ch/quick-reference/ggplot2/colour
#I also change the color of streets, small streets, and rivers
ggplot() +
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = "green3",
          size = .4,
          alpha = .8) +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "yellow",
          size = .2,
          alpha = .6) +
  geom_sf(data = river$osm_lines,
          inherit.aes = FALSE,
          color = "deepskyblue3",
          size = .2,
          alpha = .5) +
  coord_sf(xlim = c(-43.79625, -43.09908), 
           ylim = c(-23.08271, -22.74609),
           expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "grey1")
  )

#Finally, I settle on nice colors for my black-background
#map and fiddle with the coordinates defined in coord_sf()
#until I get the map coverage that I want. 
ggplot() +
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = "#7fc0ff",
          size = .4,
          alpha = .8) +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "#ffbe7f",
          size = .2,
          alpha = .6) +
  geom_sf(data = river$osm_lines,
          inherit.aes = FALSE,
          color = "#ffbe7f",
          size = .2,
          alpha = .5) +
  geom_sf(data = water_bodies$osm_lines,
          inherit.aes = FALSE,
          color = "turquoise2",
          size = .2,
          alpha = .1,
          fill = "turquoise2") +
  coord_sf(xlim = c(-43.2915, -43.14008), 
           ylim = c(-23.025, -22.84009),
           expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "gray2")
  )

#I use ggsave to define a file path where I want to save this file.
#You can also skip this step and save your map as a pdf or image
#using the export menu above the output window.
ggsave("your_file_path", width = 6, height = 6)


############################################################################
#Finally, to create a watercolor map, I download watercolor tiles from
#Stamen design: http://maps.stamen.com/watercolor/#12/37.7706/-122.3782
#To do so, I create a dataset called rio_map and use the 
#get_stamenmap function. The coordinate points used to determine the 
#limits of the map (left, bottom, right, and top) should be the same
#as those you define in your preferred version of the map. I set maptype
#as watercolor, though Stamen also offers a number of other beautiful
#map backgrounds: http://maps.stamen.com/#watercolor/12/37.7706/-122.3782

#You can adjust the zoom to determine the bluriness or detail of the tiles. 
#The higher the zoom value, the greater the sharpness, but the more tile 
#downloads required. 
rio_map <- get_stamenmap( bbox = c(left = -43.2915, bottom = -23.051, right = -43.14008, top = -22.85009), zoom = 14, maptype = "watercolor")


#To build my map of Rio over the watercolor tiles, I include my watercolor
#dataset in the ggmap() function as follows: 
ggmap(rio_map) +
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = "gray16",
          size = .4,
          alpha = .9) +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "gray16",
          size = .2,
          alpha = .9) +
  coord_sf(xlim = c(-43.2815, -43.14008), 
           ylim = c(-23.051, -22.85009),
           expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "gray2")
  )

#In this version of the map I adjust the coordinates to leave more space 
#at the bottom for a title, which I will add in Microsoft Powerpoint.
#See the PowerPoint template I have included in this repository.
ggsave("your_file_path", width = 6, height = 6)

#####################################################################################
#As an additional example, I create a watercolor map of Madison, Wisconsin. 

getbb("Madison United States")

streets <- getbb("Madison United States")%>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("motorway", "primary", 
                            "secondary", "tertiary")) %>%
  osmdata_sf()

small_streets <- getbb("Madison United States")%>%
  opq()%>%
  add_osm_feature(key = "highway", 
                  value = c("residential", "living_street",
                            "unclassified",
                            "service", "footway")) %>%
  osmdata_sf()


madison_map <- get_stamenmap( bbox = c(left = -89.52684, bottom = 42.980, right = -89.268, top = 43.16192), zoom = 14, maptype = "watercolor")


ggmap(madison_map) +
  geom_sf(data = streets$osm_lines,
          inherit.aes = FALSE,
          color = "gray24",
          size = .4,
          alpha = .8) +
  geom_sf(data = small_streets$osm_lines,
          inherit.aes = FALSE,
          color = "gray32",
          size = .2,
          alpha = .1) +
  coord_sf(xlim = c(-89.52684, -89.268), 
           ylim = c(42.981, 43.16192),
           expand = FALSE) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "gray2")
  )


ggsave("your_file_path", width = 6, height = 6)

#####################################################################################
