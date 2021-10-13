#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// srtm tiff from USGS
workflow {
	srtms = Channel
		.fromPath("/mnt/d/geodata/srtm-tiff/*.tif")
	mergeTiff(srtms.collect())
	rescale(mergeTiff.out)
	hillshade(rescale.out)
}

process mergeTiff {
	publishDir 'output'
	input: 
		path '*.tif'
	output: 
		path 'merged.tif'
	"""
	gdalbuildvrt mosaic.vrt *.tif
	gdal_translate mosaic.vrt merged.tif -of GTiff
	"""
}

process rescale {
	publishDir 'output'
	input:
		path 'merged.tif'
	output:
		path 'rescaled.tif'
	"""
	gdalwarp -t_srs EPSG:32651 -tr 100 100 -r cubic \
	-srcnodata -32767 -dstnodata 0 merged.tif rescaled.tif
	"""
}

process hillshade {
	publishDir 'output'
	input:
		path 'rescaled.tif'
	output:
		path 'shaded.tif'
	"""
	gdal_edit.py -unsetnodata rescaled.tif
	gdaldem hillshade -co COMPRESSS=LZW -z 1.5 rescaled.tif shaded.tif
	"""
}