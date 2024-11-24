#!/usr/bin/env nextflow

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
        --kit-name '${kit_name}' \\
        --emit-summary \\
        --output-dir 'demultiplexed/' \\
        ${params.no_trim ? '--no_trim' : ''} \\
        ${params.barcode_both_ends ? '--barcode_both_ends' : ''} \\
        ${params.emit_fastq ? '--emit-fastq' : ''} \\
        ${input_reads}
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
