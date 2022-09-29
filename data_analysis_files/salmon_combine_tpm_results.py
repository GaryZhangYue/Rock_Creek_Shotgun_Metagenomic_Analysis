#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jul 22 16:03:06 2021

@author: yuezhang
"""
#this file grabs the TPM column of all .sf files (SALMON output files) inside a customized dir and places them in a csv with two columns: sample name and TPM
import os
import sys
import pandas as pd
import numpy as np

# input the path of the directory of quants produced by salmon
#QUANTS_DIR='/Volumes/microbiome/chesapeake_bay_paper/test/tstquants'
QUANTS_DIR = '/home-4/yzhan231@jhu.edu/work/yuezhang/RockCreek/yzhan231_rock_creek_shotgun_p1_analysis/yzhan231_rock_creek_shotgun_p1/PreheimLab_metagenomics_SOP/metawrap_04202022/SALMON/QUANT_BINS_salmon1.5.1/quants'
# for further analysis
#OUT='/Volumes/microbiome/chesapeake_bay_paper/test/salmon_allgff_allsample.csv'
OUT='/home-4/yzhan231@jhu.edu/work/yuezhang/RockCreek/yzhan231_rock_creek_shotgun_p1_analysis/yzhan231_rock_creek_shotgun_p1/PreheimLab_metagenomics_SOP/metawrap_04202022/SALMON/QUANT_BINS_salmon1.5.1/quants/TPM_allsamples_all_refined_bins.csv'

assert os.path.exists(QUANTS_DIR)
quants_list = sorted([i for i in os.listdir(QUANTS_DIR) if i.endswith(".sf") and i.startswith('.')==False])
quants_paths = [os.path.join(QUANTS_DIR, i) for i in quants_list]
#print(quants_paths)
quants = pd.DataFrame()
for i in quants_paths:
    df1 = pd.read_csv(i,'\t')
    #print(list(df1.columns))
    tpm = df1[['Name', 'TPM']]
    sample = i[i.rfind('/')+1:i.rfind('_')]
    tpm = tpm.rename(columns={'Name':'locus_ID','TPM':sample+'_TPM'})
    if quants.empty:
        quants = tpm
    else:
        comparison_column = np.where(quants["locus_ID"] == tpm["locus_ID"], "same", "different")
        if "different" in comparison_column:
            sys.exit("name of locus ID in files do not match")
        quants = pd.merge(quants, tpm, on = "locus_ID", how = "inner")
    print(sample)
quants.to_csv(OUT)
