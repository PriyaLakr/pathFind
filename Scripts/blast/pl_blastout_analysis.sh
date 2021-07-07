#!/bin/bash


goodhits(){
	ls *_blast.out > samples_list && \
	while read i; do awk '!/^\#/' ${i} | awk -v percent_ident=$percent_iden -F "\t" '{ if ($4 >= percent_ident) print $0}' > ${i}.goodhits; done < samples_list
}


sorting(){
	ls *.goodhits > new_samples_list && \
	while read i; do sort -k2 ${i} > ${i}.sorted; done < new_samples_list
}


add_genome_size(){
	ls *.sorted > sorted_samples_list && \
	while read i; do awk 'FNR==NR{split($2,a,":"); split(a[2],b,"."); c=b[1]"."b[2]; d[c]=a[2]; split($3,f,":"); e[c]=f[2]; next}  { if (d[$2]) {$13=d[$2]; $14=e[$2]} }{print $0}' $seqinfo ${i} > ${i}.edited; done < sorted_samples_list
}


extract_reads(){
	ls *.edited > edited_samples_list
	while read i; do grep "$organismName" ${i} | awk -F " " '{print $0}' | sort -u > ${i}_organism; done < edited_samples_list
	while read i; do grep -v "$organismName" ${i} | awk -F " " '{print $0}' | sort -u > ${i}_Otherorganism; done < edited_samples_list 
	#while read i; do awk -F " " '{print $1}' | sort -u ${i} > ${i}_totalreads; done < edited_samples_list
}


usage(){
	echo "i (input_dir)                  Input directory where blastn output files are stored. Compatible with outfmt 7."
	echo "p (percent_iden)               Cut-off for percent identity (column 4). This feature will extract all hits with percent identity matching or above the user-defined value."
	echo "n (organismName)  [optional]   Name of any organism to be extracted from blastn output"
	echo "f (seqinfo)       [optional]   File containing sequence information used to generate the blast database, for instance, genome size, organism name, IDs, etc. Provided in the data folder."
}
	
	
while getopts "i:p:n:f:" opt; do
	case $opt in
		i) input_dir="$OPTARG" ;;
		p) percent_iden="$OPTARG" ;;
		n) organismName="$OPTARG" ;;
		f) seqinfo="$OPTARG" ;;
	esac
done
	
	
#if [[ -z "$@" ]]; then # if none argument is provided
if [[ -z $input_dir || -z $percent_iden ]]; then
	echo -e "\nProvide parameters:"
	usage
	echo
else
	mkdir -p $input_dir/pro_out/goodhits/"$organismName"_files && mkdir -p $input_dir/pro_out/tmp && cd $input_dir && \
	goodhits && sorting && add_genome_size && extract_reads && \
	mv *.edited $input_dir/pro_out/goodhits
	mv *_organism $input_dir/pro_out/goodhits/"$organismName"_files
	mv *.sorted *_Otherorganism *.goodhits *_list $input_dir/pro_out/tmp
	echo "Analysis complete"
fi
	
# Usage: bash pl_blastout_analysis.sh -i /Users/priyalakra/Desktop/backedup_blast_out -p 80 -n Asper -f seq.txt.fsorted 
