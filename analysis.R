# Script to calculate roost-switching
library(here) # for file paths

# Load the movement data from 2018-2021
load(here("data", "inputs", "moveStack_2018.2021.Rda"))

# Load the roost data
Roosts <- readOGR(dsn = here::here("data", "KML_Files",
                                   "20210324_RoostsNili.kml"), 
                  layer = "Roosting")

# Make a data frame of all roost coordinates
allRoostCoords <- data.frame()
for(i in 1:length(Roosts)){
  # name of the current site
  name <- as.character(Roosts@data[i, 1])
  
  # coordinates of the current site
  coords <- Roosts@polygons[[i]]@Polygons[[1]]@coords
  
  # combine the name and coordinates into a nice data frame
  data <- as.data.frame(coords) %>% 
    setNames(., c("x", "y")) %>%
    mutate("Site" = name,
           x = as.numeric(as.character(x)),
           y = as.numeric(as.character(y)))
  
  # join to the data frames from the previous sites
  allRoostCoords <- bind_rows(allRoostCoords, data)
}

# Convert polygons into st_polygon friendly format (all polygons must be closed)
roostPolys <- allRoostCoords %>%
  split(allRoostCoords$Site) %>% # split by site
  lapply(function(x) rbind(x,x[1,])) %>% # put the first row onto the end to close the polygon
  lapply(function(x) x[,1:2]) %>% # remove site names
  lapply(function(x) list(as.matrix(x))) %>% # prepare for conversion to polygons
  lapply(function(x) sf::st_polygon(x)) %>% # convert coords to polygons
  sf::st_sfc() %>% sf::st_sf(geom = .) %>% # convert to sf format
  dplyr::mutate(Stn = factor(unique(allRoostCoords$Site))) # add back the site names

# Get all points, in sf-friendly format
points <- Sp_NonFlyingPts_df %>% 
  as.data.frame() %>%
  dplyr::select(coords.x1, coords.x2, trackId) %>%
  sf::st_as_sf(., coords = c("coords.x1", "coords.x2"), remove = F)

# Find points that fall inside roost polygons
# `joined` is points that fall inside roost polygons
joined <- roostPolys %>% 
  sf::st_intersection(points) 