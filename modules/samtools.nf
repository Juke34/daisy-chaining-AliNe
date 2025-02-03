/*
http://www.htslib.org/doc/samtools-stats.html
Produces comprehensive statistics from alignment file
*/
process samtools_stats {
    label 'samtools'
    tag "$sample"
    publishDir "${params.outdir}", mode: 'copy'

    input:
        tuple val(sample), file(bam)

    output:
       path ("*.txt"), emit: bam_samtools_stats

    script:

        """
            samtools stats  ${bam} > ${bam.baseName}.txt
        """
}