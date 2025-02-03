#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//*************************************************
// STEP 0 - parameters
//*************************************************

// Input/output params
params.reads = "/path/to/reads_{1,2}.fastq.gz/or/folder"
params.genome = "/path/to/genome.fa"
params.outdir = "result_daisy_chaining_aline"
params.aligner = ''
params.read_type = "short_single" // short_paired, short_single, pacbio, ont

//*************************************************
// STEP 1 - LOG INFO
//*************************************************

// Header message
log.info """
IRD
.-./`) .-------.     ______
\\ .-.')|  _ _   \\   |    _ `''.
/ `-' \\| ( ' )  |   | _ | ) _  \\
 `-'`\"`|(_ o _) /   |( ''_'  ) |
 .---. | (_,_).' __ | . (_) `. |
 |   | |  |\\ \\  |  ||(_    ._) '
 |   | |  | \\ `'   /|  (_.\\.' /
 |   | |  |  \\    / |       .'
 '---' ''-'   `'-'  '-----'`


Example of how to daisy-chain the AliNe pipeline.
===================================================

"""

if (params.help) { exit 0, helpMSG() }

// Help Message
def helpMSG() {
    log.info """
    ********* RAIN - RNA Alterations Investigation using Nextflow *********

        Usage example:
    nextflow run main.nf --illumina short_reads_Ecoli --genus Escherichia --species coli --species_taxid 562 -profile docker -resume
    --help                      prints the help section

        Input sequences:
    --reads                     path to the illumina read file or folder
    --genome                    path to the genome 
    --aligner                   Aligner to use (See AliNe documentation for more details)
    --read_type                 type of reads among this list [short_paired, short_single, pacbio, ont] (default: $params.read_type)

        Output:
    --output                    path to the output directory (default: $params.outdir)

        Nextflow options:
    -profile                    change the profile of nextflow both the engine and executor more details on github README (https://github.com/Juke34/AliNe)
    -resume                     resume the workflow where it stopped
    """
}

// Parameter message

log.info """

General Parameters
     genome                     : ${params.genome}
     reads                      : ${params.reads}
     read_type                  : ${params.read_type}
     aligner                    : ${params.aligner}
     outdir                     : ${params.outdir}
  
 """


//*************************************************
// STEP 2 - Include needed modules
//*************************************************
include { AliNe as ALIGNMENT } from "./modules/aline.nf"
include {samtools_stats} from './modules/samtools.nf' 

//*************************************************
// STEP 3 - Deal with parameters
//*************************************************

// check profile
if (
    workflow.profile.contains('singularity') ||
    workflow.profile.contains('docker')
  ) { "executer selected" }
else { exit 1, "No executer selected: -profile docker/singularity"}


//*************************************************
// STEP 4 -  Workflow
//*************************************************

workflow {
        main:

        // Run the AliNe pipeline
        ALIGNMENT (
            'Juke34/AliNe -r v1.1.0',         // Select pipeline
            "-profile ${workflow.profile}",   // workflow opts supplied as params for flexibility
            "--reads ${params.reads}",
            "--genome ${params.genome}",
            "--read_type ${params.read_type}",
            "--aligner ${params.aligner}",
        )

        // Create a channel from the output of the AliNe pipeline (all bam files)
        ALIGNMENT.out.output
            .map { dir -> 
                files("$dir/alignment/*/*.bam", checkIfExists: true)  // Find BAM files inside the output directory
            }
            .flatten()  // Ensure we emit each file separately
            .map { bam -> tuple(bam.baseName, bam) }  // Convert each BAM file into a tuple, with the base name as the first element
            .set { aline_alignments }  // Store the channel

        local_part(aline_alignments)
}


//******************* local workflow ******************************
workflow local_part {

    take:
        tuple_sample_sortedbam

    main:

        // stat on aligned reads
        samtools_stats(tuple_sample_sortedbam)
}