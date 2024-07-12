#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Updated on Mon July 12 2024

@author: labolandry
"""

SAMPLES = ["A", "B"]

rule all:
    input:
        "calls/all.vcf", #expand("calls/{sample}.g.vcf", sample=SAMPLES), #expand("mapped_reads/{sample}.bam", sample=SAMPLES), #expand("trimmed/{sample}.fastq", sample=SAMPLES),
        "quality/multiqc_report.html"

rule fastqc:
    input:
        expand("data/samples/{sample}.fastq", sample=SAMPLES)
    output:
        "quality/{sample}_fastqc.html"
    shell:
        "fastqc {input} -o quality/"

rule multiqc:
    input: expand("quality/{sample}_fastqc.html", sample=SAMPLES)
    output: "quality/multiqc_report.html"
    wrapper: "0.31.1/bio/multiqc"


rule trimmomatic: #Single-end
    input:
        "data/samples/{sample}.fastq"
    output:
        "trimmed/{sample}.fastq"
    log:
        "logs/trimmomatic/{sample}.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        # optional compression levels from -0 to -9 and -11
        compression_level="-9"
    threads:
        32
    # optional specification of memory usage of the JVM that snakemake will respect with global
    # resource restrictions (https://snakemake.readthedocs.io/en/latest/snakefiles/rules.html#resources)
    # and which can be used to request RAM during cluster job submission as `{resources.mem_mb}`:
    # https://snakemake.readthedocs.io/en/latest/executing/cluster.html#job-properties
    resources:
        mem_mb=1024
    wrapper:
        "v3.13.6/bio/trimmomatic/se"


rule test_bowtie2:
    input:
        expand("trimmed/{sample}.fastq", sample=SAMPLES),
        ref="data/genome.fa", #Required for CRAM output
    output:
        "mapped_reads/{sample}.bam"
    log:
        "logs/bowtie2/{sample}.log",
    params:
        extra="",  # optional parameters
    threads: 8  # Use at least two threads
    wrapper:
        "v3.13.6/bio/bowtie2/align"


rule haplotype_caller_gvcf:
    input:
        # single or list of bam files
        bam=expand("mapped_reads/{sample}.bam", sample=SAMPLES),
        ref="data/genome.fa",
        # known="dbsnp.vcf"  # optional
    output:
        gvcf="calls/{sample}.g.vcf",
    #       bam="{sample}.assemb_haplo.bam",
    log:
        "logs/gatk/haplotypecaller/{sample}.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
    threads: 4
    resources:
        mem_mb=1024,
    wrapper:
        "v3.13.7/bio/gatk/haplotypecaller"


rule join_gvcfs:
    input:
        gvcfs=expand("calls/{sample}.g.vcf", sample=SAMPLES),
        ref="data/genome.fa",
    output:
        gvcf="calls/all.g.vcf",
    log:
        "logs/gatk/combinegvcfs.log",
    params:
        extra="",  # optional
        java_opts="",  # optional
    resources:
        mem_mb=1024,
    wrapper:
        "v3.13.7/bio/gatk/combinegvcfs"


rule genotype_on_gvcf:
    input:
        gvcf="calls/all.g.vcf",  # combined gvcf over multiple samples
    # N.B. gvcf or genomicsdb must be specified
    # in the latter case, this is a GenomicsDB data store
        ref="data/genome.fa"
    output:
        vcf="calls/all.vcf",
    log:
        "logs/gatk/genotypegvcfs.log"
    params:
        extra="",  # optional
        java_opts="", # optional
    resources:
        mem_mb=1024
    wrapper:
        "v3.13.7/bio/gatk/genotypegvcfs"

