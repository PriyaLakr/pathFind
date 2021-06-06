#!/bin/bash

# usage $ bash pl_qc.sh [infile path] [threads] 
input=$1  #'/data1/priya/new_data'

cd $input
mkdir output_dir
out_dir=$1/output_dir

fastqc -t $2 $input/*.fastq.gz -o $out_dir

#cd $out_dir
#multiqc . 
