#!/usr/bin/env nextflow

include {dorado_demultiplex; split} from "${projectDir}/process"

workflow "demultiplexing" {
    
    if (!params.kit_name) {
        println "You must specify a kit name using '--kit_name <kit_name>'"}

    take:
        kit_name
        input_reads

    main:
        dorado_demultiplex(kit_name, input_reads)
        split(dorado_demultiplex.out)
}