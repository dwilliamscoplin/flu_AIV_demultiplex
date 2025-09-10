#!/usr/bin/env nextflow

nextflow.enable.dsl=2

Channel
    .fromPath("${params.input_dir}/*.{pod5,fast5}")
    .ifEmpty { Channel.empty() }
    .set { raw_reads }

process dorado_basecalling {
    tag 'dorado_basecaller'
    publishDir params.output_dir, mode: 'copy'

    input:
    val model_arg
    val input_dir
    val min_qscore
    val no_trim
    val barcode_both_ends
    val emit_fastq
    val output_dir

    output:
    path "output", emit: basecalled

    script:
    """
    dorado basecaller \\
        ${model_arg} \\
        ${input_dir} \\
        --device auto \\
        --min-qscore '${min_qscore}' \\
        ${no_trim ? '--no-trim' : ''} \\
        | dorado demux \\
        --output-dir "output" \\
        ${no_trim ? '--no-trim' : ''} \\
        ${barcode_both_ends ? '--barcode-both-ends' : ''} \\
        ${emit_fastq ? '--emit-fastq' : ''} \\
        --emit-summary \\
        --barcode-sequences "${projectDir}/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcode_arrs_cust.toml" \\
        --verbose
    """
}

process dorado_demultiplex {
    tag 'dorado_demux'
    publishDir params.output_dir, mode: 'copy'

    input:
    val input_dir
    val no_trim
    val barcode_both_ends
    val emit_fast_q
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
        --barcode-sequences "${projectDir}/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcode_arrs_cust.toml" \\
        ${input_dir}
    """
}

workflow {
    if (raw_reads){
        println "POD5/FAST5 files detected, proceeding with basecalling..."

        if (!params.model_arg) {
            --model_arg hac@v0.9.1+c8c2c9f
        }
    }
        dorado_basecalling(
           params.model_arg,
           params.input_dir,
           params.min_qscore,
           params.no_trim,
           params.barcode_both_ends,
           params.emit_fastq,
           params.output_dir
        )
    } else {
        println "No POD5/FAST5 files detected, proceeding with demultiplexing..."
        dorado_demultiplex(
          params.input_dir,
          params.no_trim,
          params.barcode_both_ends,
          params.emit_fastq,
          params.output_dir
       )
    }

