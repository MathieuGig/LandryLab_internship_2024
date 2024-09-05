#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Updated on Mon July 12 2024

@author: labolandry
"""

SAMPLES = ["NS.2209.003.UDP0161_i7---UDP0161_i5.fRS1_", "NS.2209.003.UDP0163_i7---UDP0163_i5.fRS757_"]
READS = ["R1", "R2"]

rule all:
    input:
        #expand("rg_reads/{sample}.rg.sorted.bam.bai", sample=SAMPLES),
        #"calls/all.vcf"
        "quality/multiqc_report.html"

rule fastqc:
    input:
        "/project/chlandry/projects/gapp/GAPP_Pilote_3_samples_Run_2209/{sample}{read}.fastq.gz" # VARIES WITH INPUT DATA
    output:
        "quality/{sample}{read}_fastqc.html"
    shell:
        "fastqc {input} -o quality/"

rule multiqc:
    input: expand("quality/{sample}{read}_fastqc.html", sample=SAMPLES, read=READS)
    output: "quality/multiqc_report.html"
    wrapper: "0.31.1/bio/multiqc"


rule trimmomatic_pe:
    input:
        r1="/project/chlandry/projects/gapp/GAPP_Pilote_3_samples_Run_2209/{sample}R1.fastq.gz",
        r2="/project/chlandry/projects/gapp/GAPP_Pilote_3_samples_Run_2209/{sample}R2.fastq.gz"
    output:
        r1="trimmed/{sample}R1.fastq.gz", # TO MODIFY
        r2="trimmed/{sample}R2.fastq.gz",
        # reads where trimming entirely removed the mate
        r1_unpaired="trimmed/{sample}R1_unpaired.fastq.gz",
        r2_unpaired="trimmed/{sample}R2_unpaired.fastq.gz"
    log:
        "logs/trimmomatic/{sample}.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"
    threads:
        32
    resources:
        mem_mb=1024
    wrapper:
        "v3.13.7/bio/trimmomatic/pe"

rule bwa_mem2_map:
    input:
        "C_albicans_SC5314_version_A22-s07-m01-r195_chromosomes.fasta",
        "trimmed/{sample}R1.fastq.gz",
        "trimmed/{sample}R2.fastq.gz"
    output:
        "mapped_reads/{sample}.bam"
    shell:
        "bwa-mem2 mem {input} | samtools view -Sb - > {output}"


rule samtools_sort:
    input:
        "mapped_reads/{sample}.bam"
    output:
        "sorted_reads/{sample}.sorted.bam"
    shell:
        "samtools sort -T sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output}"


rule modify_read_groups:
    input:
        "sorted_reads/{sample}.sorted.bam"
    output:
        "rg_reads/{sample}.rg.sorted.bam"
    shell:
        "samtools addreplacerg -r 'ID:{wildcards.sample}' -r 'LB:2209' -r 'PL:ILLUMINA' -r 'PU:testing001' -r 'SM:{wildcards.sample}' -o {output} {input}"

rule samtools_index:
    input:
       "rg_reads/{sample}.rg.sorted.bam"
    output:
        "rg_reads/{sample}.rg.sorted.bam.bai"
    shell:
        "samtools index {input}"

rule haplotype_caller_vcf:
    input:
        # single or list of bam files
        expand("rg_reads/{sample}.rg.sorted.bam.bai", sample=SAMPLES),
        expand("rg_reads/{sample}.rg.sorted.bam", sample=SAMPLES)
    output:
        "calls/all.vcf"
#    log:
#        "logs/gatk/haplotypecaller/all.log",
    shell:
        "gatk --java-options '-Xmx4g' HaplotypeCaller " + ''.join(expand("-I rg_reads/{sample}.rg.sorted.bam ", sample=SAMPLES)) + "-R C_albicans_SC5314_version_A22-s07-m01-r195_chromosomes.fasta -O {output}"
#    params:
#        extra="",  # optional
#        java_opts="",  # optional
#    threads: 4
#    resources:
#        mem_mb=1024,
#    wrapper:
#        "v3.13.8/bio/gatk/haplotypecaller"
