#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set default model argument
def model_arg = params.model_arg ?: 'hac@v0.8.3'

process dorado_demultiplex {
    tag 'dorado_demux'
    publishDir params.input_dir, mode: 'copy'

    input:
    val input_dir
    val no_trim
    val barcode_both_ends
    val emit_fastq
    val output_dir

    output:
    path "output", emit: demultiplexed

    script:
    """
    dorado demux \\
        --output-dir "output" \\
        ${no_trim ? '--no-trim' : ''} \\
        ${barcode_both_ends ? '--barcode-both-ends' : ''} \\
        ${emit_fastq ? '--emit-fastq' : ''} \\
        --barcode-sequences "${projectDir}/barcodes/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcodes/barcode_arrs_cust.toml" \\
        --kit-name "BC" \\
    """
}

workflow {
    
            dorado_demultiplex(
                params.input_dir,
                params.no_trim,
                params.barcode_both_ends,
                params.emit_fastq,
                params.output_dir
            )
        }


