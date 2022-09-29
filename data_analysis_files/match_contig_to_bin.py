#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 14:52:54 2022

@author: yuezhang
"""
#this script takes a directory containing .fasta files as input, output a csv with a column of .fasta file name and a column of contig names (the line starts with '>' in each .fasta file)

#prefix and suffix of .fasta file names to match 
prefix = 'bin'
suffix = '.faa'
#path to input directory
fasta = '/home-4/yzhan231@jhu.edu/work/yuezhang/RockCreek/yzhan231_rock_creek_shotgun_p1_analysis/yzhan231_rock_creek_shotgun_p1/PreheimLab_metagenomics_SOP/metawrap_04202022/BIN_ANNOTATION/bin_translated_genes'
#path and name of output file
output = fasta + '/' + 'match_contig_to_bin.txt'
import os
import sys
import pandas as pd
import numpy as np

assert os.path.exists(fasta)

fasta_list = sorted([i for i in os.listdir(fasta) if i.endswith(suffix) and i.startswith(prefix)])
fasta_paths = [os.path.join(fasta, i) for i in fasta_list]

df = pd.DataFrame()

fasta_name = []
contig_name = []
for i in fasta_paths:
    for line in open(i,'r'):
        if line[0] != '>': continue
        fasta_name.append(os.path.basename(i))
        contig_name.append(line.rstrip())

df = pd.DataFrame({'bin':fasta_name,
                   'contig':contig_name})

#set index as a column
df.reset_index(inplace=True)

df.to_csv(output, sep = '\t', header= True, index = False)

