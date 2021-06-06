#!/bin/bash

# usage: bash pl_trim.sh [infile path] [threads]

cd $1
mkdir trim_out
trim=$1/trim_out

for infile in *_R1_final.fastq.gz;
do  name=$(basename $infile _R1_final.fastq.gz); trimmomatic PE -threads $2 ${name}_R1_final.fastq.gz ${name}_R2_final.fastq.gz  $trim/${name}_R1_trim.fastq.gz  $trim/${name}_R1_untrim.fastq.gz  $trim/${name}_R2_trim.fastq.gz  $trim/${name}_R2_untrim.fastq.gz ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 MINLEN:30;
done

echo "Done!"
