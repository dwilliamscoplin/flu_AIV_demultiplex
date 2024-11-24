#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.no_trim = "false" // Optional, default is false
params.barcode_both_ends = "false" // Optional, default is false
params.emit_fastq = "false" // Optional, default is false
params.kit_name = null //User-defined parameter for the kit used
params.input_dir = './data'
params.output_dir = './output/'

process "dorado_demultiplex" {
    tag 'dorado_demux'

    publishDir "${params.output_dir}", mode: 'copy'

    input:
    val kit_name
    path input_reads
        
    output:
    path "demultiplexed/*", emit: demultiplexed
        
    script:
    """
    mkdir -p 'demultiplexed'
    
    dorado demux \\
        "${input_reads}" \\
        --kit-name '${kit_name}' \\
        --emit-summary \\
        --output-dir "demultiplexed/" \\
    """
}

process "split" {
    tag "split_and_concatenate"

    publishDir "${params.output_dir}", mode: 'copy'

    input:
    path output_dir

    output:
    path "classified" 

    script:
    """
    mkdir -p 'classified'

    for file in ${output_dir}; do
        # Extract file extension (bam or fastq)
        file_ext=\$(basename "\$file" | rev | cut -d'.' -f1 | rev)

        if [[ "\$file" =~ barcode[0-9]+ ]]; then
            # Extract barcode number from filename
            barcode_name=\$(basename "\$file" | grep -o 'barcode[0-9]\\+')
            
            #Create or append to the file for this barcode
            cat "\$file" >> "classified/\${barcode_name}.\${file_ext}"
        else
           # Append all unclassified filesinto a single file
           cat "\$file" >> "classified/unclassified.\${file_ext}"
        fi
    done
    """
}

workflow {

    if (!params.kit_name) {
        println "You must specify a kit name using '--kit_name <kit_name>'"
    }

    kit_name = Channel.value(params.kit_name)
    input_reads = Channel.fromPath("${params.input_dir}/*")
    output_dir = Channel.value(params.output_dir)    
    
    dorado_demultiplex(kit_name, input_reads)
    split(dorado_demultiplex.out)
}