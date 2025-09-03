#! /usr/bin/env nextflow

nextflow.enable.dsl=2

// Default parameter
params {
    no_trim = true // No default, must be specified
    kit_name = SQK-LSK114 // No default, must be specified
    min_qscore = 10 // Default minimum Q-score
    barcode_both_ends = false
    emit_fastq = True // No default, must be specified
    input_dir = "${/home /dawn.williams-coplin /data} /data" // Default input directory
    output_dir = "${home /dawn.williams-coplin/demux_data}/output" // Default output directory
}

raw_reads = file("${params.input_dir}").list().findAll {it.toString().endsWith('.pod5') || it.toString().endsWith('.fast5')}

process "dorado_basecalling" {
    tag 'dorado_basecaller'

    publishDir "${projectDir}", mode: 'copy'

    input:
    val model_arg
    val input_dir
    val min_qscore
    
    output:
    path "output", emit: basecalled

    script:
    """
    
    dorado basecaller \\
        ${model_arg} \\
        ${input_dir} \\
        --device auto \\
        --min-qscore '${min_qscore}'\\
        --no-trim \\
        | dorado demux \\
        --output-dir "output" \\
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

    publishDir "${projectDir}", mode: 'copy'

    input:
    val input_dir
        
    output:
    path "output", emit: demultiplexed
        
    script:
    """
        
    dorado demux \\
       --kit-name <SQK-LSK114>
        --output-dir "output" \\
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
