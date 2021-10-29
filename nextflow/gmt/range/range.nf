#!/usr/bin/env nextflow
nextflow.enable.dsl=2

cityName = 'Seoul'
range = [800, 1500, 3000]  // in km
maprange = 40  // degree

workflow {
    city = channel.of(cityName)
    getLngLat(city)
    rangeplot(getLngLat.out)
}

process getLngLat {
    // get Lng and Lat from nominatim
    input:
        val city 
    output:
        path "lnglat.csv"
    script:
        """
        curl "https://nominatim.openstreetmap.org/search.php?q=${city}&format=json" \
        | jq -r '.[0] | [.lon, .lat] | @csv' | tr -d '"' > lnglat.csv
        """
}

process rangeplot {
    publishDir 'output', mode: 'copy'
    input:
        path "lnglat.csv"
    output:
        path "range.pdf"
    script:
        diameter = [
            0,  // dummy
            *range.collect{it*2}]
        """
        gmt begin
            gmt figure range pdf
            gmt pscoast -Rd -JE125.75/39.02/${maprange}/20c -Gburlywood -Slightblue -A1000 
            gmt plot lnglat.csv -Sa.2c -Wthicker,blue
            for r in ${diameter}
            do
                gmt plot lnglat.csv -SE-\$r -Wthin,firebrick
            done
        gmt end
        """
}