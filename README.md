# pathFindB

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
	


