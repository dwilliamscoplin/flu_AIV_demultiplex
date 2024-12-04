#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.no_trim = false // Optional, default is false
params.barcode_both_ends = false // Optional, default is false
params.emit_fastq = false // Optional, default is false
params.input_dir = "${projectDir}/data"

process "dorado_demultiplex" {
    tag 'dorado_demux'

    publishDir "${projectDir}/output/", mode: 'copy'

    input:
    path input_reads
        
    output:
    path "demultiplexed/*", emit: demultiplexed
        
    script:
    """
    mkdir -p 'demultiplexed'
    
    dorado demux \\
        --output-dir "demultiplexed/" \\
        ${params.no_trim ? '--no-trim' : ''} \\
        ${params.barcode_both_ends ? '--barcode-both-ends' : ''} \\
        ${params.emit_fastq ? '--emit-fastq' : ''} \\
        --barcode-sequences "${projectDir}/barcodes/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcodes/barcode_arrs_cust.toml" \\
        ${params.input_dir}
    """
}

workflow {

    input_reads = Channel.fromPath("${params.input_dir}/*")
        
    dorado_demultiplex(input_reads)
}
