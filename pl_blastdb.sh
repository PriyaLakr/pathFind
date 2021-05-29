#!/bin/bash

#PBS -l nodes=node1:ppn=$num_thread
#PBS -N process
#PBS -o process.out
#PBS -e process.err


makedatabase(){

	if [[ -z "$taxidfile" ]]; then
		makeblastdb -in $input_file -dbtype $datatype -out $database_dir/$name -hash_index -parse_seqids  
	else
		makeblastdb -in $input_file -dbtype $datatype -out $database_dir/$name -hash_index -parse_seqids -taxid_map $taxidfile 
	fi
}


while getopts "i:t:d:n:p:f:" opt; do
	case $opt in
		i) input_file="$OPTARG" ;;
		t) datatype="$OPTARG" ;;
		d) database_dir="$OPTARG" ;;
		n) name="$OPTARG" ;;
		p) num_thread="$OPTARG" ;;
		f) taxidfile="$OPTARG" ;;
		\?) help; exit 1 ;;
	esac
done



help(){

	echo -e "Usage: \n i (input_file) Provide fasta file to make database \n t (type) provide type of database to make; protein or nucl \n d (database_dir) provide path to store database files \n n (name) provide name of the database you want to make \n p (num_thread) provide number of threads"
	exit 1
}

if [[ -z "$input_file" ]] || [[ -z "$datatype" ]] || [[ -z "$name" ]] || [[ -z "$database_dir" ]];  then
	help
else
	echo -e "\tWARNING: Before using this script make sure ncbi blast is downloaded and path is set to 'PATH' enviornment variable"
	makedatabase
	echo -e "Database generated in $database_dir" 
fi

