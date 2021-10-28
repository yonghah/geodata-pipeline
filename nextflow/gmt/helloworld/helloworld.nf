nextflow.enable.dsl=2

process plot {
	publishDir 'output'
    output:
      	path 'world.pdf'
    script:
		"""
		gmt begin 
			gmt figure world pdf
			gmt pscoast -Rd -Slightblue
		gmt end
		"""
}

workflow {
    plot()
}
