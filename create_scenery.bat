REM Set the appropriate parameters:
REM Enter the name of the region from which you want to create the scenery (without spaces)
SET DB_NAME=wroclaw

REM Enter your PostgreSQL database password
SET DB_PASS=password

REM Enter the first part of the file name you downloaded from http://download.geofabrik.de/
SET READ_PBF=dolnoslaskie

REM Enter the first part of the name of the cropped PBF file, by default it is the same name as the database name
SET WRITE_PBF=%DB_NAME%

REM Enter the folder where you store the PBF files
SET PBF_DIR=%UserProfile%\Downloads\FlightGear\osm2city

REM Enter the name of the directory where the INI file is located, by default it is the same name as the database name
SET INI_DIR=%DB_NAME%

REM Provide crop coordinates with TerraGear GUI (http://wiki.flightgear.org/TerraGear_GUI)
SET LATITUDE_MIN=51.02
SET LATITUDE_MAX=51.19
SET LONGITUDE_MIN=16.91
SET LONGITUDE_MAX=17.17

REM Enter the number of processor cores for parallel scenery processing
SET CPU_THREAD=4

REM ==========================================================================
REM Auxiliary variables:
REM The default should be postgres and you don't have to change it
SET DB_USER=postgres

REM This is needed to prevent PostgreSQL from asking for a password
SET PGPASSWORD=%DB_PASS%

REM Path with the name to the cropped PBF file
SET PBF_CROPPED=%PBF_DIR%\%WRITE_PBF%-cropped.pbf

SET ASTERISK=
IF "%LONGITUDE_MIN:~0,1%" == "-" (
	REM If LONGITUDE_MIN is with minus sign, then set ASTERISK according to docs: https://osm2city.readthedocs.io/en/latest/generation.html
	SET ASTERISK=*
)

REM ==========================================================================

REM We are deleting the database so as to be sure that createdb will succeed
dropdb --username=%DB_USER% -e %DB_NAME%

REM We create a database
createdb --encoding=UTF8 --owner=%DB_USER% --username=%DB_USER% %DB_NAME%
psql --username=%DB_USER% -c "CREATE EXTENSION postgis;" --dbname=%DB_NAME%
psql --username=%DB_USER% -c "CREATE EXTENSION hstore;" --dbname=%DB_NAME%
psql --username=%DB_USER% -f "%UserProfile%\Documents\FlightGear\osm2city-work\osmosis\script\pgsnapshot_schema_0.6.sql" -d %DB_NAME%
psql --username=%DB_USER% -f "%UserProfile%\Documents\FlightGear\osm2city-work\osmosis\script\pgsnapshot_schema_0.6_bbox.sql" -d %DB_NAME%

IF EXIST "%PBF_CROPPED%" (
    REM Delete the cropped PBF file if it exists
    DEL "%PBF_CROPPED%"
)

REM Crop a pbf file
CALL osmosis\bin\osmosis.bat --read-pbf file="%PBF_DIR%\%READ_PBF%-latest.osm.pbf" --bounding-box completeWays=yes top=%LATITUDE_MAX% left=%LONGITUDE_MIN% bottom=%LATITUDE_MIN% right=%LONGITUDE_MAX% --write-pbf file="%PBF_CROPPED%"

REM Import cropped pbf into the database
CALL osmosis\bin\osmosis.bat --read-pbf file="%PBF_CROPPED%" --log-progress --write-pgsql database=%DB_NAME% host=localhost:5432 user=%DB_USER% password=%DB_PASS%

REM Create indexes for the database
psql --username=%DB_USER% -c "CREATE INDEX idx_nodes_tags ON nodes USING gist(tags);" --dbname=%DB_NAME%
psql --username=%DB_USER% -c "CREATE INDEX idx_ways_tags ON ways USING gist(tags);" --dbname=%DB_NAME%
psql --username=%DB_USER% -c "CREATE INDEX idx_relations_tags ON relations USING gist(tags);" --dbname=%DB_NAME%

REM Generate the scenery, remember to create the params.ini file
REM Doc build_tiles: https://osm2city.readthedocs.io/en/latest/generation.html
REM Doc ini: https://osm2city.readthedocs.io/en/latest/parameters.html
CALL osm2city\build_tiles.py -f projects\%INI_DIR%\params.ini -b %ASTERISK%%LONGITUDE_MIN%_%LATITUDE_MIN%_%LONGITUDE_MAX%_%LATITUDE_MAX% -p %CPU_THREAD%

REM Delete the database and clean up after ourselves
dropdb --username=%DB_USER% -e %DB_NAME%

