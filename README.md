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
- **Input FASTQ files**: Add your basecalled reads (fastq.gz or bam files) to the data/ directory.
- **Custom barcode primers and barcode arrangements**: Provided within the workflow

## Usage
  Run the workflow using the following command:
   ```bash
   nextflow run main.nf
   
# Optional
--emit_fastq: Specify to generate FASTQ output instead of default BAM.
--no_trim: Disable trimming of barcode sequences.
--barcode_both_ends: Enable demultiplexing based on barcodes at both ends.
```
## Output
The workflow produces demultiplexed BAM or FASTQ files separated by barcode.

## References
- [Protocol for Influenza A Custom Barcoded Primers](https://www.protocols.io/view/optimized-rt-pcr-protocols-for-whole-genome-amplif-bp2l62r15gqe/v1)
- [Related Research Paper](https://doi.org/10.3389/fcimb.2024.1497278)
