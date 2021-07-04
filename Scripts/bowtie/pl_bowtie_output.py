def analyse(path):
    """
    Analyse bowtie output files
    
    Parameters
    ----------
    path : path to the directory where input files are located. Input files should be in .txt format.
        
        
    Returns
    -------
    CSV files containing reads information including mapped and unmapped read segments, genomic covearge of reads, NCBI-IDs and organisms.
    """
    
    os.chdir(path)
    os.mkdir('output')
    new_path=os.path.join(path,'output')
    
    nic = pd.read_csv("ncbiid.csv",header=None)
    names = pd.read_csv("names.csv", sep=" ", header=None)

    
    for infile in os.listdir(path):
        if infile.endswith("txt"):
            f_name=infile.split('.')[0]
            
            file = pd.read_csv(infile, sep="\t", header=None)
            file = file.assign(**{"ncbi_id": nic,"names":names})
            file.rename(columns = {0:'Organism',1:'Genome_size', 2:f'{f_name}_mapped_read_segments', 3:f'{f_name}_unmapped_read_segments'}, inplace=True)

            # keep rows where mapped reads is not zero
            new_file = file.loc[file[f'{f_name}_mapped_read_segments'] > 0, :]
            
            # add read length and genome coverage columns 
            # new_file["read_length"] = [161 for i in range(len(new_file['Organism']))]
            new_file.insert(4, "read_length", [161 for i in range(len(new_file.index))], True)
            
            # calculate genome coverage and then add to the data frame
            cal = (new_file[f'{f_name}_mapped_read_segments'] * new_file['read_length']) / new_file['Genome_size']
            #  new_file["genome_coverage"] = cal  #assigning like this creates a settingWithCopyWarning
            new_file.insert(5, "genome_coverage", cal, True)
            
            
            # select rows with > 10 genome coverage and save to a new file
            final_file = new_file.loc[new_file["genome_coverage"] > 10, :]
            final_file.to_csv(f'{new_path}/{infile}.csv',index=False)
            
    return new_path


def combine_data(new_path):
    """
    Merge two or more dataframes by common keys
    
    Parameters
    ----------
    path : path to the directory where input .csv files are located
        

    Returns
    -------
    concatenated .csv files by common organisms
    """
    
    from functools import reduce
   
    os.chdir(new_path)
    os.mkdir('final_output')
    final_path=os.path.join(new_path,'final_output')
    
    names = []
    for infile in os.listdir(new_path):
        if infile.endswith("csv"):
            f_name=infile.split('.')[0]
            file = pd.read_csv(infile)
            new_file = file[['Organism',f'{f_name}_mapped_read_segments']]
            names.append(new_file)
    
    namesf = reduce(lambda left,right: pd.merge(left,right,on=['Organism'],
                                            how='outer'), names)  # outer: use union of keys from both frames
    namesf = namesf.fillna(0)
    namesf = namesf.reindex(sorted(namesf.columns), axis=1) #sorting columns by their name
    namesf = namesf.set_index('Organism')
    namesf.to_csv(f"{final_path}/file.csv", index=True)


if __name__ == "__main__":

    import argparse  
    import os
    import pandas as pd

    parser = argparse.ArgumentParser(description = "This script is for analysing bowtie output files")

    parser.add_argument("--path", type=str, help="Path of the directory where input files are stored")

    args = parser.parse_args()
    path = args.path

    new_path = analyse(path)
    combine_data(new_path)
    
    from datetime import datetime
    print(f"\n   Analysis completed at {datetime.now().strftime('%H:%M:%S')}  \n")
