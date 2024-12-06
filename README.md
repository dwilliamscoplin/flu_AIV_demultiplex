# Nextflow Workflow for Demultiplexing Influenza A Nanopore Libraries Prepared with Custom Barcodes

## Overview
This repository contains a **Nextflow workflow** for demultiplexing Nanopore reads from NGS libraries prepared with **Influenza A whole genomes**, amplified using **custom barcoded primers**. The workflow is optimized for custom barcode sets and tailored specifically for Influenza A whole-genome sequencing applications.

## Prerequisites
To use this workflow, ensure you have the following installed:
- **Nextflow** (version >= 21.10.0)  
  [Installation Guide](https://www.nextflow.io/docs/latest/install.html)
- **Dorado** (for Nanopore basecalling)  
  [Dorado Repository](https://github.com/nanoporetech/dorado)
  
## Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/Dorado_FluA_Custom_Demultiplexing.git
   cd Dorado_FluA_Custom_Demultiplexing
2. Install Nextflow if not already installed:
   ```bash
   curl -s https://get.nextflow.io | bash
3. Install Dorado if not already installed:
   ```bash
   curl "https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.8.3-linux-x64.tar.gz" -o dorado-0.8.3-linux-x64.tar.gz
   tar -xzf dorado-0.8.3-linux-x64.tar.gz
   dorado-0.8.3-linux-x64/bin/dorado --version

## Workflow Inputs
- **Input files**: Add your raw (.pod5 or .fast5) or already basecalled (fastq.gz or bam files) reads to the data/ directory.
- **Custom barcode primers and barcode arrangements**: Provided within the workflow in the barcodes directory.

## Usage
- **For raw (.pod5 or .fast5)** reads run the workflow using the following command:
   ```bash
   nextflow run main.nf <model> --min_qscore <number>

   #Options:
   <model>: specify model speed (fast, hac, or sup) to automatically select a basecalling model.
   <number>: specify number to discard reads with mean Q-score below this threshold.
   --emit_fastq: specify to generate FASTQ output instead of default BAM.
   --no_trim: disable trimming of barcode sequences.
   --barcode_both_ends: Enable demultiplexing based on barcodes at both ends.e
  ```

  This workflows will first basecall raw reads and then demultiplex them. 
   
- **For existing basecalled (.bam, .fastq, .fastq.gz) datasets** run the workflow using the following command:
   ```bash
   nextflow run main.nf

   #Options:
   --emit_fastq: Specify to generate FASTQ output instead of default BAM.
   --no_trim: Disable trimming of barcode sequences.
   --barcode_both_ends: Enable demultiplexing based on barcodes at both ends.
  ```

## Output
This workflow results in multiple BAM files being generated in the output folder, one per barcode (formatted as NAME_BARCODEXX.bam) and one for all unclassified reads. As with the in-line mode, --emit_fastq, --no_trim, and --barcode_both_ends are also available as additional options.

## References
- [Protocol for Influenza A Custom Barcoded Primers](https://www.protocols.io/view/optimized-rt-pcr-protocols-for-whole-genome-amplif-bp2l62r15gqe/v1)
- [Related Research Paper](https://doi.org/10.3389/fcimb.2024.1497278)
