#! /usr/bin/env nextflow

nextflow.enable.dsl=2

params.min_qscore = null // User-defined parameter to discard reads with mean Q-score below this threshold. [nargs=0..1] [default: 0]
params.no_trim = false // Optional, default is false
params.barcode_both_ends = false // Optional, default is false
params.emit_fastq = false // Optional, default is false
params.input_dir = "${projectDir}/data"

raw_reads = file("${params.input_dir}").list().findAll {it.toString().endsWith('.pod5') || it.toString().endsWith('.fast5')}

process "dorado_basecalling" {
    tag 'dorado_basecaller'

    publishDir "${projectDir}/output", mode: 'copy'

    input:
    val model_arg
    val input_dir
    val min_qscore
    
    output:
    path "basecalled/*", emit: basecalled

    script:
    """
    mkdir -p 'basecalled'

    dorado basecaller \\
        ${model_arg} \\
        ${input_dir} \\
        --device auto \\
        --min-qscore '${min_qscore}'\\
        --no-trim \\
        | dorado demux \\
        --output-dir "basecalled/" \\
        ${params.no_trim ? '--no-trim' : ''} \\
        ${params.barcode_both_ends ? '--barcode-both-ends' : ''} \\
        ${params.emit_fastq ? '--emit-fastq' : ''} \\
        --emit-summary \\
        --barcode-sequences "${projectDir}/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcode_arrs_cust.toml" \\
        --verbose      
    """
}

process "dorado_demultiplex" {
    tag 'dorado_demux'

    publishDir "${projectDir}/output", mode: 'copy'

    input:
    val input_dir
        
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
        --barcode-sequences "${projectDir}/custom_barcodes.fasta" \\
        --barcode-arrangement "${projectDir}/barcode_arrs_cust.toml" \\
        ${input_dir}
    """
}

workflow {

    if (raw_reads) {
        println "POD5/FAST5 files detected, proceeding with basecalling..."
        
        if (!args || args.size () !=1) {
            error "You must specify a model selection using '<fast, hac, or sup>'. Use <fast,hac,sup>@v<version> for automatic model selection"
        }

        if (!params.min_qscore) {
            error "You must specify a parameter to discard reads with mean Q-score below this threshold using '--min_qscore <number>'"
        }

    model_arg = args[0]

    input_dir = params.input_dir
    min_qscore = params.min_qscore
    
    dorado_basecalling(model_arg, input_dir, min_qscore)

    } else {
        println "No POD5/FAST5 files detected, proceeding with demultiplexing..."

        input_dir = params.input_dir
        
        dorado_demultiplex(input_dir)
    }
}
