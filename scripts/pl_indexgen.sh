#!/bin/bash

#PBS -l nodes=node1:ppn=50
#PBS -N indexing
#PBS -o indexgen.out
#PBS -e indexgen.err

cd ~
source activate pathseq ## activate the conda enviornment where bowtie2 is installed

bowtie2-build /home/priya/pl_pathogen_database/all_path.fasta  /home/priya/pl_pathogen_database/all_pathogen.bowtie2.refB --threads 50 --large-index   

conda deactivate

echo "done"
