#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Set default model argument
def model_arg = params.model_arg ?: 'hac@v0.8.3'

// Channel for raw input files (pod5/fast5)
raw_reads = Channel.fromPath("${params.input_dir}/*.{pod5,fast5}", checkIfExists: true)
has_raw_reads = raw_reads.map { true }.ifEmpty { false }.first()

// Channel for fastq.gz files (for direct demux)
fastq_files = Channel.fromPath("${params.input_dir}/*.fastq.gz", checkIfExists: true)

process dorado_basecalling {
    tag 'dorado_basecaller'
    publishDir params.output_dir, mode: 'copy'

    input:
    path reads
    val model_arg
    val min_qscore
    val no_trim
    val barcode_both_ends
    val emit_fastq
    val output_dir

    output:
    path "output/*.fastq", emit: basecalled_fastq

    script:
    """
    dorado basecaller \\
        ${model_arg} \\
        ${reads} \\
        --device auto \\
        --min-qscore '${min_qscore}' \\
        ${no_trim ? '--no-trim' : ''} \\
        | dorado demux \\
        --output-dir "output" \\
        ${no_trim ? '--no-trim' : ''} \\
        ${barcode_both_ends ? '--barcode-both-ends' : ''} \\
        ${emit_fastq ? '--emit-fastq' : ''} \\
        --emit-summary \\
        --barcode-sequences "${projectDir}/barcodes/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcodes/barcode_arrs_cust.toml" \\
        --verbose
    """
}

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
    if (has_raw_reads) {
        // run dorado_basecalling

            dorado_basecalling(
                raw_reads,
                model_arg,
                params.min_qscore,
                params.no_trim,
                params.barcode_both_ends,
                params.emit_fastq,
                params.output_dir
            )

        } else {
          // run dorado_demultiplex

            dorado_demultiplex(
                fastq.gz_files,
                params.no_trim,
                params.barcode_both_ends,
                params.emit_fastq,
                params.output_dir
            )
        }
    }


