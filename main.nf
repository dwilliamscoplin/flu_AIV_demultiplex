#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.no_trim = false // Optional, default is false
params.barcode_both_ends = false // Optional, default is false
params.emit_fastq = false // Optional, default is false
params.kit_name = null //User-defined parameter for the barcoding kit used 
params.input_dir = './data'
params.output_dir = './output'

kit_name = Channel.value(params.kit_name)
input_reads = Channel.fromPath("${params.input_dir}/*")
output_dir = Channel.value(params.output_dir)

include { demultiplexing } from "${projectDir}/workflow"
workflow {

    main:
        demultiplexing(kit_name, input_reads)
}