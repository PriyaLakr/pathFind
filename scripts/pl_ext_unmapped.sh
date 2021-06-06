#!/bin/bash

echo -e "Starting to extract unmapped reads on $(date) \n pl_ext_unmapped.sh [infile/infolder path] [output dir name]"

cd $1
mkdir $2
out=$1/$2

for i in *.bam; do samtools view -h -b -f 4 ${i} > $out/${i}.unmapped_reads.bam; done   # f4 flag extract all unmapped reads

echo -e "Process completed!"
