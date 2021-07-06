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


while getopts "i:p:n:f:" opt; do
	case $opt in
		i) input_dir="$OPTARG" ;;
		p) percent_iden="$OPTARG" ;;
		n) organismName="$OPTARG" ;;
		f) seqinfo="$OPTARG" ;;
	esac
done
	
	
if [[ -z "$@" ]]; then
	echo -e "Provide path to the directory containing input files and percentage identify value"
else
	mkdir -p $input_dir/pro_out/goodhits/"$organismName"_files && mkdir -p $input_dir/pro_out/tmp && cd $input_dir && \
	goodhits && sorting && add_genome_size && extract_reads && \
	mv *.edited $input_dir/pro_out/goodhits
	mv *_organism $input_dir/pro_out/goodhits/"$organismName"_files
	mv *.sorted *_Otherorganism *.goodhits *_list $input_dir/pro_out/tmp
	echo "Analysis complete"
fi
	
# Usage: bash pl_blastout_analysis.sh -i /Users/priyalakra/Desktop/backedup_blast_out -p 80 -n Asper -f seq.txt.fsorted 