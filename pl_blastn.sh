#!/bin/bash

#PBS -l nodes=node1:ppn=40
#PBS -N blastn
#PBS -o blastn.out
#PBS -e blastn.err

## variables d == infile directory

source activate pathseq

echo $dir
echo $dbdir

cd $dir
mkdir blast_out

outd=$dir/blast_out

for i in *.fasta; do blastn -db $dbdir/all_patho -num_alignments 30 -query ${i} -out $outd/${i}_blast.out -outfmt 7 -perc_identity 50 -evalue 0.01 -num_threads 40; done

conda deactivate

