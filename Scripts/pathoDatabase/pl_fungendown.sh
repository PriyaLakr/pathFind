#!/bin/bash

cd $1

mkdir fung_database
cd $1/fung_database

start=$(date +%s)

fungdown() {
	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/fungi/assembly_summary.txt' | \
	awk '{FS="\t"} !/^#/ {print $20} ' | \
	sed -r 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fna.gz|' > genomic_file_fungi

	#cat genomic_file_fungi | xargs -n 1 -P 8 wget -nc -q
	xargs -n 1 -P 8 curl -O < genomic_file_fungi
}

if [ -f $1/fung_database/genomic_file_fungi ]; then
	echo "check folder first and delete any previous files"
else
	fungdown
fi

end=$(date +%s)

echo "Process completed in $(( ($end - $start)/60 )) minutes"
