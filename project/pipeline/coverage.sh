#!/bin/bash

#SBATCH -D /home/magig218/pipeline/third_test/rg_reads
#SBATCH -J bed
#SBATCH -o bedtools-%j.out
#SBATCH -c 2
#SBATCH -p small
#SBATCH --mail-type=None
#SBATCH --mail-user=magig218@ulaval.ca
#SBATCH --time=0-00:40:00
#SBATCH --mem=21200

#declare -a List

#ls -1 NS*.rg.sorted.bam > list

#samtools coverage -m -A -q 10 -b list 

#my_bam=NS.2209.003.UDP0161_i7---UDP0161_i5.fRS1_.rg.sorted.bam
#my_bam=NS.2209.003.UDP0163_i7---UDP0163_i5.fRS757_.rg.sorted.bam
#my_bam=NS.2209.003.UDP0167_i7---UDP0167_i5.A12_.rg.sorted.bam


my_bams=( NS.2209.003.UDP0161_i7---UDP0161_i5.fRS1_.rg.sorted.bam
          NS.2209.003.UDP0163_i7---UDP0163_i5.fRS757_.rg.sorted.bam
)

#output_name=output_bed_sample161
#output_name=output_bed_sample163
#output_name=output_bed_sample167


for i in ${my_bams[@]} ; do
    output_name=v2_output_bed_$i
    bedtools genomecov -ibam $i -bg > $output_name
done

#scp $output_name labolandry@132.203.168.176:/home/labolandry/Desktop/GiguereM_VariantCalling/stage-ete2024/project/pipeline/
