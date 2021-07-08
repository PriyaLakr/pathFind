def blast_analysis(path):
    """
    Analyse blast output files
    
    Parameters
    ----------
    path : path to the directory where input files are located. Input files should be in .txt format.
        
        
    Returns
    -------
    CSV files containing reads information including mapped read count, genomic covearge of reads, NCBI-IDs and organisms.
    """
	

	import os
	import pandas as pd
	
	os.chdir(path)
	os.mkdir('output')
	new_path=os.path.join(path,'output')
	
	
	for infile in os.listdir(path):
		if infile.endswith("txt"):
			s_name=infile.split('.')[0]
			f_name=s_name
			file = pd.read_csv(infile, sep=" ", header=None)
			file.rename(columns = {0:f'Query_{f_name}',1:'subject_name',2: '%identity', 3:'alignment_length',4:'mismatches',5:'gap_opens',6:'q.start',7:'q.end',8:'s.start',9:'s.end',10:'e_val',11:'bit_Score',12:'Organism_info',13:'genome_size'}, inplace=True)
			edited_file=list(enumerate(file.groupby('subject_name')))
			
			
			ls={}
			lt={}
			for i,j in edited_file:
				x=len(j[1])
				t=j[1]
				name=t['Organism_info'].values[0]
				genomesize=t['genome_size'].values[0]
				ls[name]=x
				lt[name]=genomesize
				
			df1=pd.DataFrame(ls.items(), columns=[f'Organism_info: {f_name}', 'readCounts'])
			df2=pd.DataFrame(lt.items(), columns=[f'Organism_info: {f_name}', 'genomesize'])
			
			df=df1.merge(df2) # how='inner' by default, use intersection of keys from both frames, similar to a SQL inner join; preserve the order of the left keys
			genome_coverage = (df['readCounts'] * 161) / df['genomesize']
			df.insert(3, 'genome_coverage', genome_coverage)
			df.to_csv(f'{new_path}/{infile}.csv',index=True)
    
            
if __name__ == "__main__":
	
	import argparse
	parser = argparse.ArgumentParser(description=blast_analysis.__doc__)
	parser.add_argument("--path", type=str, help="path where input files are located")
	args = parser.parse_args()
		
	blast_analysis(args.path)
	
# run `python pl_blast_output.py --help` for help!
