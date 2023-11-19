raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d 
"C:\Users\natii\OneDrive\Pulpit\BDP\dane_cw7\srtm_1arc_v3.tif" 
rasters.dem > "C:\Users\natii\OneDrive\Pulpit\BDP\dane_cw7\dem.sql"

raster2pgsql.exe -s 3763 -N -32767 -t 100x100 -I -C -M -d
"C:\Users\natii\OneDrive\Pulpit\BDP\dane_cw7\srtm_1arc_v3.tif" 
rasters.dem | psql -d bdp_cw7_raster
-h localhost -U postgres -p 5432

raster2pgsql.exe -s 3763 -N -32767 -t 128x128 -I -C -M -d
"C:\Users\natii\OneDrive\Pulpit\BDP\dane_cw7\Landsat8_L1TP_RGBN.tif" 
rasters.landsat8 | psql
-d postgis_raster -h localhost -U postgres -p 5432
