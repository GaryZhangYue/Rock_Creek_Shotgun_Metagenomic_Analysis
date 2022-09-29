# Rock_Creek_Shotgun_Metagenomic_Analysis
Metagenomic sequence assembly, binning, functional/taxonomic annotation, reads quantification, and data analysis

# Notes:
This repository is associated with the preliminary analysis of the shotgun metagenomic sequencing data for a few selected samples. More samples are being sequenced and analyzed.

# Contents
Directory bioinformatic_bash_files/ contains the bash files used to call MetaWRAP modules and other bioinformatics software to process the shotgun sequencing data.
Directory data_analysis_files/ contains the Python and R codes for downstream data analysis and visualization.

Contents of bioinformatic_bash_files/ :
- annotate_bins_using_metawrap.sh : functional annotation of MAGs
- assembly_metawrap.sh : de novo assembly
- bin_refinement_using_metawrap.sh : consolidate of multiple binning predictions into a superior bin set
- binning.sh : initial bin extraction with MaxBin2, metaBAT2, and CONCOCT
- binning_to_end.sh : a shell wrapper to run binning, bin_refinement and reassembly sequentially 
- classify_bins_using_GTDB-Tk.sh : taxonomic classification of bins with GTDB-Tk
- classify_bins_using_metawrap.sh taxonomic classification of bins with metawrap module
- concatenate_bins.sh : concatenate each bin.fa file into one all_bin.fa file
- prokka_on_all_scaffolds.csh : functional annotation of contigs using Prokka
- reassembly_using_metawrap.sh : reassemble bins to improve completion and N50, and reduce contamination
- rename_bin_to_fna.sh : changes the suffix of bins from .fa to .fna to fulfill GTDB-Tk input requirements 
- salmon_on_bins.sh : estimate bin abundance across samples
- rename.sh : change sample name to meaningful names

Contents of data_analysis_files/ :
- match_contig_to_bin.py : produce a .txt file that links bin.faa file to the associated contig IDs
- salmon_combine_tpm_results.py :  parse the salmon output and generate a .csv file showing the TPM of each locus in every sample
- morris_gene_selection.py : select locus associated with targeted KEGG numbers
- shorten_contig_names.py : shorten the contig names
- dir environmental_sample_analysis: R codes, inputs and visualization of the taxonomic/functional annotation of bins
- dir zymo_community_analysis : R codes, inputs and visualization of the comparison of the positive control sample (zymo community) between theoretical values and results

