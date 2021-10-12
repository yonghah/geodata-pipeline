#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.country = 'new-caledonia,fiji,vanuatu'  // default value
country = Channel.from(params.country.tokenize(','))

workflow {
	download(country)
	tagFilter(download.out)
	toGeojson(tagFilter.out)
	mergeAll(toGeojson.out.collect())
	toCsv(mergeAll.out)
}
process download {
	input: val country
	output: path "country.osm.pbf"
	"""
	download-osm geofabrik ${country} --state state.txt -o country.osm.pbf
	"""
}
process tagFilter {
	input: path 'input.pbf' 
	output: path "filtered.pbf" 
	"""
	osmium tags-filter input.pbf n/amenity=restaurant -o filtered.pbf
	"""
}
process toGeojson {
	input: path "filtered.pbf" 
	output: path "filtered.geojson" 
	"""
	ogr2ogr -f GeoJSON filtered.geojson filtered.pbf points
	"""
}
process mergeAll {
	publishDir 'output'
	input: path '*.geojson' 
	output: path 'merged.geojson' 
	"""
	ogrmerge.py -o merged.geojson *.geojson -f GeoJSON -single
	"""
}
process toCsv {
	publishDir 'output'
	input: path "merged.geojson" 
	output: path "merged.csv" 
	"""
	jq -r '
		["name", "lng", "lat"],
		(.features[] | [
			.properties.name, 
			.geometry.coordinates[0], 
			.geometry.coordinates[1]]) 
		| @csv' \
	merged.geojson > merged.csv
	"""
}
