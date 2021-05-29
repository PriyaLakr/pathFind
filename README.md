# pathoFind

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
	
	 bash pl_qc.sh [options]


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


















Scripts for aligning reads from NGS data using BLAST. 

# 1: Aligning against database using NCBI-BLAST+ 


1.1. Downloading standalone NCBI-BLAST+ 
	
	wget https://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/ncbi-blast-2.11.0+-x64-linux.tar.gz
	tar -zxvpf ncbi-blast-2.11.0+-x64-linux.tar.gz


1.2. Making BLAST database

	bash pl_blastdb.sh [options]

	blastdbcheck -db <database_name> -dbtype nucl -must_have_taxids 
	
can also mask low complexity regions before making database


1.3. BLASTn search 

	qsub -v dbdir=/nfs_node1/priya/blast_database,dir=/nfs_node1/priya/blast_trial pl_blastn.sh

# 2. Output analysis

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
	


