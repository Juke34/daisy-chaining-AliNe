Daisy chaining AliNe
=========================================  
<img align="right" src="img/IRD.png" width="200" height="66" /> <img align="right" src="img/MIVEGEC.png" width="100" height="66" />


This repository provides an example of how to integrate an external Nextflow pipeline, such as [AliNe](https://github.com/Juke34/AliNe), into another pipeline seamlessly.


   * [Foreword](#foreword)
   * [Installation](#installation)
      * [Nextflow](#nextflow)
      * [Container platform](#container-platform)
        * [Docker](#docker)
        * [Singularity](#singularity)  
   * [Usage and test](#usage)

## Foreword 

The example pipeline, daisy-chaining-aline, consists of two steps. The first step calls AliNe and retrieves the sorted BAM file it generates. The second step represents the continuation of the pipeline—here, for simplicity, it runs samtools stats as a demonstration.

AliNe is a Nextflow-based pipeline designed for efficient read alignment against a reference genome using various alignment tools of your choice. For more details, visit the [AliNe repository](https://github.com/Juke34/AliNe).

## Installation

The prerequisites to run the pipeline are:  

  * [Nextflow](https://www.nextflow.io/)  >= 22.04.0
  * [Docker](https://www.docker.com) or [Singularity](https://sylabs.io/singularity/)  

### Nextflow 

  * Via conda 

    <details>
      <summary>See here</summary>
      
      ```bash
      conda create -n nextflow
      conda activate nextflow
      conda install bioconda::nextflow
      ```  
    </details>

  * Manually
    <details>
      <summary>See here</summary>
      Nextflow runs on most POSIX systems (Linux, macOS, etc) and can typically be installed by running these commands:

      ```bash
      # Make sure 11 or later is installed on your computer by using the command:
      java -version
      
      # Install Nextflow by entering this command in your terminal(it creates a file nextflow in the current dir):
      curl -s https://get.nextflow.io | bash 
      
      # Add Nextflow binary to your user's PATH:
      mv nextflow ~/bin/
      # OR system-wide installation:
      # sudo mv nextflow /usr/local/bin
      ```
    </details>

### Container platform

To run the workflow you will need a container platform: docker or singularity.

### Docker

Please follow the instructions at the [Docker website](https://docs.docker.com/desktop/)

### Singularity

Please follow the instructions at the [Singularity website](https://docs.sylabs.io/guides/latest/admin-guide/installation.html)

## Usage

### Help

You can first check the available options and parameters by running:

```bash
nextflow run Juke34/daisy-chaining-aline -r v1.0.0 --help
```

### Profile

To run the workflow you must select a profile according to the container platform you want to use:   
- `singularity`, a profile using Singularity to run the containers
- `docker`, a profile using Docker to run the containers

The command will look like that: 

```bash
nextflow run Juke34/daisy-chaining-aline -r v1.0.0 -profile docker <rest of paramaters>
```

### Example

A typical command might look like the following.  
Here, we use the docker container platform, remote read and genome files, specify that we use single-ended short reads, list a number of aligners, enable trimming with fastp and provide specific options for the star aligner.

```bash
nextflow run Juke34/daisy-chaining-aline \
  -r v1.0.0 \
  -profile docker \
  --reads https://github.com/Juke34/AliNe/raw/refs/heads/main/test/illumina/yeast_R1.fastq.gz,https://github.com/Juke34/AliNe/raw/refs/heads/main/test/illumina/yeast_R2.fastq.gz \
  --genome https://raw.githubusercontent.com/Juke34/AliNe/refs/heads/main/test/yeast.fa \
  --read_type short_single \
  --aligner hisat2,bowtie2
```
