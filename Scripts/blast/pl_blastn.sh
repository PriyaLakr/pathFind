#!/bin/bash

#PBS -l nodes=node1:ppn=40
#PBS -N blastn
#PBS -o blastn.out
#PBS -e blastn.err

## variables dir == infile directory; dbdir == database directory; outformat == outformat of blast required

echo $dir
echo $dbdir
echo $outformat

cd $dir
mkdir blast_out

outd=$dir/blast_out

for i in *.fasta; do blastn -db $dbdir/all_patho -num_alignments 30 -query ${i} -out $outd/${i}_blast.out -outfmt $outformat -perc_identity 50 -evalue 0.0001 -num_threads 40; done

echo "Process completed"

