#!/bin/bash

## below function extracts unmapped reads from bam files and calls bam2fastq function
ext_unmapped(){
	echo -e "\tExtracting unmapped reads...."
	start=$(date +%s)

	cd $input_dir
	
	for j in *.bam; do samtools view -h -b -f 4 ${j} > $out/${j}.unmapped_reads.bam; done   # f4 flag extract all unmapped reads

	bam2fastq
	end=$(date +%s)
	echo -e "Process completed in $(( ($end - $start)/60 )) mins"
}


## below function converts bam files to fastq format
bam2fastq(){
	cd $out
	for j in *.unmapped_reads.bam; do samtools fastq ${j} > $out_new/${j}.fastq; done 
}


## below function aligns fastq files to your choice of index using bowtie2 aligner. This function requires that bowtie2 index is prebuilt. For making bowtie2 index, refer to pl_indexgen.sh script or bowtie2 manual
align(){
	echo -e "\tAligning......"
	cd $out_new

	if [[ "$filetype" == "interleaved" ]]; then 
		for j in *.$infilesuffix; do bowtie2 -x  $indexlocation/$index_file_name --interleaved ${j}  --$run_mode  --threads $number_of_threads  -S $out_dir_path/${j}_nhu_out.sam; done; 
	fi

	##if [[ "$filetype" == "separate" ]] && [[ -z $frwd_read_file ]] && [[ -z $rev_read_file ]]; then  
		##frwd_prefix=$(basename frwd_suffix)
		##rev_prefix=$(basename frwd_suffix)
 		##for j in *.fastq; do bowtie2 -x  $indexlocation/$index_file_name -1 ${frwd_prefix}${frwd_suffix} -2 ${rev_prefix}${rev_suffix} --$run_mode --threads $number_of_threads  -S $out_dir_path/${j}_nhu_out.sam > ${j}_alnStat.txt; done;
		##bowtie2 -x  $indexlocation/$index_file_name -1 ${frwd_read_file} -2 ${rev_read_file} --$run_mode --threads $number_of_threads  -S $out_dir_path/${sample_prefix}_nhu_out.sam > ${sample_prefix}_alnStat.txt
	##else
		##echo "Parameters missing! Check help!"
	##fi
}

processing(){
	echo -e "\tProcessing sam files.....\n"
	start=$(date +%s)

	echo -e "Files should be in sam/bam format"

	cd $out_dir_path
	mkdir processed_files
	pr_out=$out_dir_path/processed_files

	mkdir final_stats
	out_stats=$out_dir_path/final_stats

	numfiles=0
	for j in *.sam; do (( numfiles=numfiles + 1 )); done

	for j in *.sam; do samtools view -bS ${j} > $pr_out/${j}.bam; done

	cd $pr_out

	for j in *.bam; do samtools sort ${j} > ${j}.out.sorted.bam; done  ## && ? these 3 for loops might throw some error when run in parallel as input in one is dependent on output from other: check this
	
	for sortedfile in *.out.sorted.bam; do samtools index ${sortedfile}.out.sorted.bam; done 

	for z in *.out.sorted.bam; do samtools idxstats ${z} > $out_stats/${z}.idxstats.txt; done

	end=$(date +%s)

	echo "Total time taken for $numfiles files is $(( ($end - $start)/60 )) mins"
}


help(){
	echo ""
	echo -e "Usage:\n"
	echo -e "-i (input_dir)          Provide input directory path where sam and/or fastq files are located\n"
	echo -e "-f (filetype)           Present script processes only paired-end reads. Provide input file type; whether paired reads are interleaved or provided as separate files\n"
	echo -e "-d (out_dir_path)       Provide output directory path where aligned sam files will be stored\n"
	echo -e "-t (number_of_threads)  Provide number of threads\n"
	echo -e "-l (indexlocation)      Provide location of bowtie2 index\n"
	echo -e "-x (index_file_name)    Provide prefix of bowtie2 index file\n"
	echo -e "-e (extractreads)       Specify 'y' to run extract reads function. It will extract unmapped reads from aligned bam files\n"
	echo -e "-a (alignreads)         Specify 'y' to run align function. It will align unmapped reads using bowtie2\n"
	echo -e "-r (bowtie2_run_mode)   Provide run mode for bowtie2 alignment. Two options: local or  end-to-end \n"
	echo -e "-p (process_reads)      Specify 'y' to run processing function. It will process the output files and return idx stats\n"
	echo -e "-s (infile suffix)      Provide suffix of input file, i.e, fastq or fq\n"
	exit 1
}


while getopts "i:f:d:t:e:a:l:p:r:x:s:" opt; do
	case $opt in
		i) input_dir="$OPTARG" ;; # ok
		f) filetype="$OPTARG" ;; # ok
		d) out_dir_path="$OPTARG" ;; # ok
		s) infilesuffix="$OPTARG" ;; # ok
		t) number_of_threads="$OPTARG" ;; # ok
		e) extractreads="$OPTARG" ;;
		a) alignreads="$OPTARG" ;; # ok
		l) indexlocation="$OPTARG" ;; # ok
		p) process_reads="$OPTARG" ;; # ok
		r) run_mode="$OPTARG" ;; # ok
		x) index_file_name="$OPTARG" ;; # ok
		\?) help;exit 1 ;; # print help function and exit
	esac
done


#Print helpFunction in case parameters are empty
if [ -z "$input_dir" ] || [ -z "$out_dir_path" ] || [ -z "$number_of_threads" ] || [ -z "$run_mode" ] || [ -z "$index_file_name" ] || [ -z "$filetype" ] || [ -z "$indexlocation" ] ; then
   echo "ERROR! Check Parameters!";
   help
fi

if [ -z "$extractreads" ] && [ -z "$alignreads" ] && [ -z "$process_reads" ]; then
   echo "ERROR! Specify features you want to run!";
   help
fi


mkdir -p $input_dir/extract_out/fastqout 
out=$input_dir/extract_out # ok
out_new=$out/fastqout


if [[ "$extractreads" == "y" ]] && [[ $input_dir ]]; then # ok
	echo -e "\tInput directory is $input_dir"
	## start with extracting unalignmed reads from sam files
	ext_unmapped 
	## convert bam to fastq
	bam2fastq
else
	echo "User already have unaligned read files"
	out_new=$input_dir
fi


if [[ "$alignreads" == "y" ]]; then
	echo -e "\tRun mode is $run_mode\n index file is located at $indexlocation\n file format is $filetype"
	## align reads
	align
else
	echo "User already have aligned read files"
fi


if [[ "$process_reads" == "y" ]]; then
	## process output files and give their idx stats 
	processing
else
	echo "Processing not required by user"
fi

echo "=======Your analysis is completed! Check you results. Both computationally and biologically!!======="
