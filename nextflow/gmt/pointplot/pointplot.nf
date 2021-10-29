#!/usr/bin/env nextflow
nextflow.enable.dsl=2

workflow {
    earthquake()
    pointplot(earthquake.out)
}

process earthquake {
    publishDir 'output'
    output:
        path "earthquake.csv"
    script:
        site = "https://earthquake.usgs.gov/fdsnws/event/1/query.csv"
        date_from = "2020-09-01"
        date_to = "2020-10-01"
        time = "starttime=${date_from}%2000:00:00&endtime=${date_to}%2000:00:00"
        minmag = "3"
        order = "magnitude"
        """
        curl -s "${site}?${time}&minmagnitude=${minmag}&orderby=${order}" > earthquake.csv
        """
}

process pointplot {
    publishDir 'output'
    input:
        path "earthquake.csv"
    output:
        path "earthquake.pdf"
    script:
        """
        gmt begin
            gmt figure earthquake pdf
            gmt pscoast -Rg -JK180/22c -B45g30 -Gburlywood -Slightblue -A1000 
            gmt plot -Sc0.1c -Wfaint -hi1 -i2,1 earthquake.csv
        gmt end
        """
}