#!/bin/bash
# Joshua Tellier, Purdue University, 2/16/2020
# The purpose of this script is to process the contents of a StationData sub-directory based upon the specific conditions outlined in the lab.

### PART ONE ###
if [ ! -d "./HigherElevation/" ] #if the destination directory does not exist
then
   mkdir HigherElevation #create it
   echo Directory Created
else
   echo Directory Already Exists #verify it already exists
fi

for file in StationData/*
do
   output=$(grep -l "Station Altitude: [200,*]" $file) #output becomes the name of any filepath within the directory in which the altitude is greater than or equal to 200
   if [ "x$output" = "x" ] #if the number of character in $output is less than 1 (i.e. the current file does not show elevation ge 200
   then
      continue #skip this iteration and go to the next
   else
   inter=$(basename "$output") #get only file basename
   cp ./StationData/$inter ./HigherElevation/ #copy it to the higher elevation directory
   fi
done

### PART TWO ###

awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list #create a list of longitude points for all stations
awk '/Latitude/ {print $NF}' StationData/Station_*.txt > Lat.list #create a list of latitude points for all stations
paste Long.list Lat.list > AllStations.xy #combine lat-long lists for all stations

##Next 3 lines --> same as above but only for HE stations
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list
awk '/Latitude/ {print $NF}' HigherElevation/Station_*.txt > HELat.list
paste HELong.list HELat.list > HEStations.xy

module load gmt 

gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Ia/blue -Na/orange -P -K -V -Cblue -Dh > SoilMoistureStations.ps #create the map to overlay our points, option -Cblue makes lakes blue, option -Dh uses high resolution political boundaries
gmt psxy AllStations.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps #all stations as black circles
gmt psxy HEStations.xy -J -R -Sc0.10 -Gred -O -V >> SoilMoistureStations.ps #high elevation stations as red circles, slightly smaller using -Sc0.10

### PART THREE ###
ps2epsi SoilMoistureStations.ps #convert .ps to .epsi
convert -density 150x150 SoilMoistureStations.epsi SoilMoistureStations.tiff #convert .epsi to .tiff and set dpi at 150
