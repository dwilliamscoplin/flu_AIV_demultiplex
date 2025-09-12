#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set default model argument
def model_arg = params.model_arg ?: 'hac@v0.8.3'

// Channel for fastq.gz files (for direct demux)
fastq.gz_files = Channel.fromPath("${params.input_dir}/*.fastq.gz", checkIfExists: true)

process dorado_demultiplex {
    tag 'dorado_demux'
    publishDir params.output_dir, mode: 'copy'

    input:
    path fastq.gz_files
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
        ${fastq.gz_files}
    """
}

workflow {
    
            dorado_demultiplex(
                fastq.gz_files,
                params.no_trim,
                params.barcode_both_ends,
                params.emit_fastq,
                params.output_dir
            )
        }


