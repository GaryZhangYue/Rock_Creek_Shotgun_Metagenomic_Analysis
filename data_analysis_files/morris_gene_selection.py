#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 30 13:16:25 2021

@author: yuezhang
"""

import os, sys
import pandas as pd
import numpy as np




f1 = "/Volumes/microbiome/chesapeake_bay_paper/spreheim/prokka/prokka_curated/metabolic_process_of_interest_from_sarah.txt"
f2 = "/Volumes/microbiome/rock_creek_anlysis/rock_creek_shotgun_sequencing_analysis/user_ko-4.txt"
f3 = "/Volumes/microbiome/rock_creek_anlysis/rock_creek_shotgun_sequencing_analysis/Prokka/PROKKA_12062021.ffn"
# create a dictionary where KO is a key, the value would be list of [genename, C level classification of function, B level classification of metabolism]

ko_dir = {}
B = None
C = None

for line in open(f1):
    if line.startswith("B"):
        if len(line) <3:
            pass
        else:
            B = line[9:].strip()
    elif line.startswith("C"):
        if len(line) < 3:
            pass
        else:
            C = line[11:line.find('[')].strip()
    elif line.startswith("D"):
        kogene = line[line.find('K'):line.find(';')]
        ko = kogene[:kogene.find('  ')]
        gene = kogene[kogene.find('  ')+2 : ]
        if ko in ko_dir:
            ko_dir[ko].append([gene, B, C])
        else:
            ko_dir[ko] = []
            ko_dir[ko].append([gene, B, C])


# this is a subset of genes in ko_interest, selected by Morris
ko_morris_tmp=[362,363,366,367,368,370,371,372,374,376,380,381,390,392,394,395,2108,2109,2110,2111,2112,2113,2114,2115,2305,2567,2568,2586,2588,2591,2634,2635,2636,2637,2638,2639,2640,2641,2689,2691,2692,2693,2694,2703,2704,2705,2706,2707,2708,3385,3388,3389,3390,4561,5301,8264,10534,10535,10944,10945,10946,11180,11181,15864,15876,17222,17223,17224,17225,17226,17227,17229,17230,23995,22482,22622,8906,1601]
# this is just to tranform the numbers to be KO identifier
ko_morris = []
for ko_tmp in ko_morris_tmp:
    ko_tmp = str(ko_tmp)
    if len(ko_tmp) < 5:
         ko_tmp = "0"*(5 - len(ko_tmp)) + ko_tmp
    ko = 'K' + ko_tmp
    if len(ko) != 6:
        print('wrong')
    ko_morris.append(ko)

# here is just the same thing as above
gene_list = []
ko_list = []
metabolism_b_list = []
metabolism_c_list = []
for i in ko_morris:
    if i in ko_dir:
        for m in ko_dir[i]:
            ko_list.append(i)
            gene_list.append(m[0])
            metabolism_b_list.append(m[1])
            metabolism_c_list.append(m[2])
    else:
        gene_list.append(i + 'not found')
df_ko_gene_morris = pd.DataFrame({'KO' : ko_list, 'gene' : gene_list, 'metabolism_b' : metabolism_b_list,
                                  'metabolism_c' : metabolism_c_list})

df_ko_gene_morris['metabolism_b'] = df_ko_gene_morris.groupby(['KO'])['metabolism_b'].transform(lambda x : ",".join(x)) 
df_ko_gene_morris['metabolism_c'] = df_ko_gene_morris.groupby(['KO'])['metabolism_c'].transform(lambda x : ",".join(x)) 
df_ko_gene_morris = df_ko_gene_morris.drop_duplicates() # 78 rows (same number of the ko_morris list) exist in this df

file2 = open(f2,'r')
file2_lines = file2.readlines()

ko_list = []
locus_id_list = []
for line in file2_lines:
    if '\t' in line:
        locus_id = line.split('\t')[0]
        KO = line.split('\t')[1][:-1]
        if KO in ko_morris:
            ko_list.append(KO)
            locus_id_list.append(locus_id)
df_ko_locus_id = pd.DataFrame({'KO':ko_list, 'locus_id':locus_id_list})

file3 = open(f3,'r')
i = False
for line in file3.readlines():
    if line.startswith(">"):
        locus_id = line.split(' ')[0][1:]
        if locus_id in locus_id_list:
            with open('/Volumes/microbiome/rock_creek_anlysis/rock_creek_shotgun_sequencing_analysis/morris_ko_selected_ffn.txt', "a") as ffn:
                ffn.write(line)
            i = True
        else:
            i = False
            continue
    else:
        if i == True:
            with open('/Volumes/microbiome/rock_creek_anlysis/rock_creek_shotgun_sequencing_analysis/morris_ko_selected_ffn.txt', "a") as ffn:
                ffn.write(line)

df_ko_locusid_gene = pd.merge(df_ko_locus_id,df_ko_gene_morris, on= 'KO', how = 'left')   
df_ko_locusid_gene.to_csv('/Volumes/microbiome/rock_creek_anlysis/rock_creek_shotgun_sequencing_analysis/ko_locusid_gene.csv')    
    



