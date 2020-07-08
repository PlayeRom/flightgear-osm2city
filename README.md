# flightgear-osm2city
Script for build FlightGear scenery from OpenStreetMap

Based on the instructions from http://wiki.flightgear.org/Howto:Using_osm2city.py_on_Windows

Assumptions:
* You have created directory `osm2city-work` in your `C:\Users\<your user name>\Documents\FlightGear\`
* In `osm2city-work` directory you have unzipped `osm2city`, `osm2city-data` and `osmosis`
* In `osm2city-work` directory you have `projects` directory where is a directory named as your scenery with `params.ini` file inside
* You have created your output directory, e.g. in `C:\Users\<your user name>\Documents\FlightGear\Custom Scenery\<your dir>`

Edit `create_scenery.bat` and change parameters inside:
* DB_NAME - the uniques name of your scenery (without spaces)
* DB_PASS - password to your PostgreSQL database
* READ_PBF - the first part of the file name you downloaded from http://download.geofabrik.de/ e.g. for `dolnoslaskie-latest.osm.pfb` it will be `dolnoslaskie`.
* PBF_DIR - the path where is located pfb file which you downloaded from http://download.geofabrik.de/
* LATITUDE_MIN, LATITUDE_MAX, LONGITUDE_MIN, LONGITUDE_MAX - crop coordinates which you can read from TerraGear GUI (http://wiki.flightgear.org/TerraGear_GUI)
* CPU_THREAD - number of processor cores for parallel processing of scenery

Then put the `create_scenery.bat` file in `osm2city-work` directory and run it.

The structure of directories:
```
C:\Users\<your user name>\Documents\FlightGear\
|
+---- Custom Scenery\<your-output-scenery-dir>
|
+---- osm2city-work
      |
      +---- osm2city
      |
      +---- osm2city-data
      |
      +---- osmosis
      |
      +---- projects
      |     |
      |     +---- <your-secenry-name> <- the same as DB_NAME
      |           |
      |           +---params.ini
      |
      +---- create_scenery.bat
```

