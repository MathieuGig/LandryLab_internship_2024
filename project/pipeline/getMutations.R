#if (!require("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")

#BiocManager::install("VariantAnnotation")

library(VariantAnnotation)

getwd()

#fl <- system.file("extdata", "C:/Users/User/Documents/GitHub/stage-ete2024/project/pipeline/all.vcf", package="VariantAnnotation")

fl <- "C:/Users/User/Documents/GitHub/stage-ete2024/project/pipeline/all.vcf"

vcf <- readVcf(fl, "calls")

samples(header(vcf))


reference <- ref(vcf)
mutations <- alt(vcf)

df <- data.frame(reference, mutations)

#ref_genome <- "C:/Users/User/Documents/GitHub/stage-ete2024/project/synth_genome/my_synthetic_genome.txt"
#library(BSgenome.Hsapiens.UCSC.hg19)
#library(TxDb.Hsapiens.UCSC.hg19.knownGene)
#txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene
#coding <- predictCoding(vcf, txdb, seqSource=ref_genome)