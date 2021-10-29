#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// lat lng from this
// curl "https://nominatim.openstreetmap.org/search.php?q=Pyongyang&format=json" \
// | jq '.[0] | {lat, lon}'

workflow {
    city = channel.of('Pyongyang')
    getLngLat(city)
    rangeplot(getLngLat.out)
}

process getLngLat {
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
        range = [0, 30*2, 1500*2, 3000*2, 5000*2, 10000*2]
        """
        gmt begin
            gmt figure range pdf
            gmt pscoast -Rd -JE125.75/39.02/120/20c -Gburlywood -Slightblue -A1000 
            for r in ${range}
            do
                gmt plot lnglat.csv -SE-\$r -Wthin,firebrick
            done
        gmt end
        """
}