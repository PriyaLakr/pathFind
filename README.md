# pathoFind

Author: Priya Lakra

Identifying non-human reads in human NGS data

This is the pipeline for identyfing non-human reads in human NGS data. The workflow contains three steps including substratcion of human reads, identification of non-human reads, and analysis.

OS and softwares used:

System details: HPC cluster; OS= Centos 7

| Softwares | Version |
| --------- | --------|
| fastqc	 |	0.11.9 |
| multiqc  	 |	1.10	|
| trimmomatic    |  0.39	| 
| bowtie2   	| 2.3.5.1 	|
| STAR 		| 2.7.8a	|
| NCBI-Blast+	| 2.11.0	|
| Python 	|	3.7.10  |
| samtools 	| 1.9		|

All scripts are in the script folder!! 🤓

Create your working enviornment 

	conda create --name env 
	 
Activate your working enviornment 

	conda activate env
	
# 1: Substratcion of human reads

1.1. Quality check using fastqc, multiqc

`bash pl_qc.sh [options]`

1.2. Trim adapters 

Change trimmomatic parameters depending on your fastq files, and perform fastqc also on trimmed output files 

	 bash pl_trim.sh [options]

1.3a. For RNAseq data, STAR aligner is used  https://physiology.med.cornell.edu/faculty/skrabanek/lab/angsd/lecture_notes/STARmanual.pdf
1.3b. For WGS data, BWA/bowtie2 aligner is used 

Mapped reads from step1.3a,b can be used for their respective analysis. 
Unmapped reads from step1.3a,b will be the input for step2 of the workflow.

# 2: Identification of non-human reads

It can be achieved via two ways, one involving Bowtie2 aligner and one involving NCBI-BLAST+

2.1. Creating bowtie2 index 

2.1a. For bacteria, fungi, and viruses, sequences were taken from [NCBI-RefSeq] (ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/) genomic sequences database

The script makes a text file (genomic_file) containing ftp links of all bacterial RefSeq sequences and download all sequences 

	bash pl_bacgendown.sh [path_name]		

Similarly, download fungal and viral sequences

	bash pl_fungendown.sh [path_name]

	mkdir viral
	wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/filename.fna.gz 

	gzip *.fna (optional)

Concatenate files to create a single fasta file containing all sequences

	cat *.fna > in_file.fna

Downloading pathogenic bacterial sequences from PATRIC [optional]

	mkdir patric_pathogens

	for i in `cat patric_genomes2.txt`; do wget -qN "ftp://ftp.patricbrc.org/genomes/$i/$i.fna";
	done
    
2.1b. Formatting fasta header name (optional):

	for i in *.fna; do awk -F '[/^> ]' 'NF>1 {print ">"$2"."$3"."$4"."$5"."$6"."$7"."$8;next}{print$1}' ${i} > ${i}_header_edited.fna; done



2.2. Making reference genome index
        
	 qsub pl_indexgen.sh ## qsub command is used here for submitting the job script to HPC.

Note: Here I generated index for ~100Gb fasta file using bowtie2-build. The process took ~20 hours.   

2.3. Align with bowtie2 and processing output sam files

	bash pl_masterscript.sh [options]

# 4. Output analysis

Output analysis incclude calculating genome coverage for each organism. 
> Genome coverage = (read length * number of reads)/genome size

Note: For read lengths, I took median read length following these calculations:
	
count read lengths in sam or bam files

	for i in *.out.sorted.bam; do samtools view -F 4 ${i} | awk '{print length($10)}' > /nfs_master/priya/nonhuman_out/processed_files/read_len/${i}.len.txt; done
	a <- read.csv('len.txt', header=FALSE)
	colnames(a) <- lengths # set col name as lengths 
	mean(a$lengths)
	median(a$lengths)
	shapiro.test(a$lengths[1:5000]) # for normality test!


Output analysis is performed using pandas package of python! 
	
	pl_out_analysis.ipynb 

Visualization is done using R!
	
	install.packages("pheatmap")
	library(pheatmap)
	
	fil <- read.csv("filename.csv", sep=",")
	
	# replace NA with zeros
	fil[is.na(fil)] = 0
	
	# select columns with numbers only to make heatmap
	filn <- as.matrix(fil[ ,3:33])
	
	# change row names to the organim names (optional)
	rownames(filn) <- fil$Organism 
	
	# scale values in the matrix (optional)
	filn_s <- scale(filn)
	
	# plotting heatmap
	pheatmap(filn_s)
	pheatmap(filn)
	
Scripts for aligning reads from NGS data using BLAST. 

# 5: Aligning against database using NCBI-BLAST+ 


5.1. Downloading standalone NCBI-BLAST+ 
	
	wget https://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/ncbi-blast-2.11.0+-x64-linux.tar.gz
	tar -zxvpf ncbi-blast-2.11.0+-x64-linux.tar.gz


5.2. Making BLAST database

	bash pl_blastdb.sh [options]

	blastdbcheck -db <database_name> -dbtype nucl -must_have_taxids 
	
can also mask low complexity regions before making database


5.3. BLASTn search 

	qsub -v dbdir=/nfs_node1/priya/blast_database,dir=/nfs_node1/priya/blast_trial pl_blastn.sh

# 6. Output analysis

Output analysis include calculating genome coverage for each organism. 
 .........coming


Note: For read lengths, I took median read length following these calculations:
	
count read lengths in sam or bam files

	for i in *.out.sorted.bam; do samtools view -F 4 ${i} | awk '{print length($10)}' > /path/to/outputFolder/${i}.len.txt; done

using R

	a <- read.csv('len.txt', header=FALSE)
	colnames(a) <- lengths # set col name as lengths 
	mean(a$lengths)
	median(a$lengths)
	shapiro.test(a$lengths[1:5000]) # for normality test!

Further output analysis is performed using pandas package of python! 
	
	pl_blastout_analysis.ipynb 

Visualization is done using R!
	


