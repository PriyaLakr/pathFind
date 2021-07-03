#!/bin/bash

help(){
  echo ""
  echo -e "i (input_dir)      path to the directory containing input files"
  echo -e "s (infile_suffix)  suffix of input files; eg, for paired-end reads, some_name_R1.fastq.gz some_name_R2.fastq.gz, suffix would be R2.fastq.gz"
  echo -e "t (num_thread)     number of threads"
  echo -e "k (keepBothReads)  Type TRUE to keep both reads after trimming"
  echo -e "a (adapter_file)   name of the adapter file"
  echo -e "m (min_len)        min read length feature"
  echo -e "\tensure that raw files and adaptor file for trimmomatic are in the same input directory"
  exit 1
  
}

while getopts "i:s:t:o:m:a:l:" opt; do
    case "$opt" in:
      i ) input_dir="$OPTARG" ;;
      s ) infile_suffix="$OPTARG" ;;
      t ) num_thread="$OPTARG" ;;
     # o ) output_dir="$OPTARG" ;;
      k ) keepBothReads="$OPTARG" ;;
      a ) adapter_file="$OPTARG" ;;
      l ) min_len="$OPTARG" ;;
      \? ) help; exit 1 ;;
     esac
   done
   
cd $input_dir
mkdir -p $input_dir/trim_out

start=$(date +%s)

for infile in *${infile_suffix};
  do name=$(basename $infile ${infile_suffix}); trimmomatic PE -threads $num_thread ${name}${infile_suffix} ${name}${infile_suffix}  $input_dir/trim_out/${name}_R1_trim.fastq.gz  $input_dir/trim_out/${name}_R1_untrim.fastq.gz  $input_dir/trim_out/${name}_R2_trim.fastq.gz  $input_dir/trim_out/${name}_R2_untrim.fastq.gz ILLUMINACLIP:${adapter_file}:2:30:10:8:${keepBothReads} MINLEN:${min_len}
done

end=$(date +%s)

echo -e "\tProcess completed in ( ($end - $start)/60 ) minutes"

