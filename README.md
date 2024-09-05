
# stage-ete2024

Code produced during my 2024 summer internship.

### Notable files or directories:

'multiqc_report.html' : Output of MULTIQC on the last test
using 2 *Candida albicans* samples.

'Snakefile' : The pipeline in Snakemake format. Dependencies: bwa-mem2 (v2.2.1), FASTQC (v0.11.8), GATK (v4.1.4.1), MULTIQC (v1.9),
Python (v3.12), samtools (v1.8), Snakemake (v8.18.2), Trimmomatic (v0.39). 

'project/' : directory storing other code and output files from my project.

'project/synth_genome/V4_GiguereM_makeSynthGenome.ipynb' : Jupyter notebook
to make the synthetic genome.

'project/pipeline/v2_analysevcfTables.ipynb' : Jupyter notebook
to analyse the table file made by GATK VariantsToTable.

'project/pipeline/v2_IdentifySpeciesFromCoverage' : Jupyter notebook
to identify the species of a fungal pathogen.
