#!/bin/bash

cd $1

mkdir bac_database
cd $1/bac_database

start=$(date +%s)
bacdown() {
	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt' | \
	awk '{FS="\t"} !/^#/ {if($12=="Complete Genome") print $20} ' | \
	sed -r 's|(ftp://ftp.ncbi.nlm.nih.gov/genomes/all/.+/)(GCF_.+)|\1\2/\2_genomic.fna.gz|' > bac_genomic_file


	#cat bac_genomic_file | xargs -n 1 -P 8  -nc -q  #wget not working in mac 
	xargs -n 1 -P 8 curl -O < bac_genomic_file
}

if [ -f $1/bac_database/bac_genomic_file ]; then ##modify it to multiple files like .txt and .gz
	echo "check folder first and delete any previous files"
else
	bacdown
fi

end=$(date +%s)

echo "Process completed in $(( ($end - $start)/60 )) minutes"
