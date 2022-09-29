
require('stringr')
require("phyloseq")
require('vegan')
require("tidyr")
require('ggplot2')
require('qiime2R')
require('dplyr')
require('ANCOMBC')
require('usedist')
require('rioja')
require('ggpubr')
require('circlize')
require('ComplexHeatmap')
require('spaa')
require('ape')
require('cowplot')
require('wesanderson')
require('ggforestplot')
require('GGally')
require('scales')
require('metagMisc')
require('iCAMP')
require('tibble')

cn =  read.table('match_refined_bin_to_contig.csv', sep = '\t', header = T, row.names = 1)
tpm = read.table('TPM_allsamples_all_refined_bins.csv', sep = ',', header = T, row.names = 1,check.names = F)
gtdb = read.table('gtdbtk.bac120.summary.tsv', sep = '\t',header = T, check.names = F)
#remove '>' in the contig column in df1
cn$contig = sub('>','',cn$contig)

#match tpm to bins via contig name in the two dfs
summary(cn$contig[order(cn$contig)] == tpm$locus_ID[order(tpm$locus_ID)]) #sanity check
btpm = merge(x = cn, y = tpm,
             by.x = 'contig', by.y = 'locus_ID',
             all.y = T)
#remove contig column
btpm = btpm[,-1]
#calculate sum for each bin across all samples
btpm = aggregate(.~bin, btpm,sum)
#rename bin
btpm$bin = sub('.fa','',btpm$bin,)
#parse the gtdb results
tax = gtdb[,c(1,2)]
tax %>% 
  subset(select = 'classification', drop = F) %>% 
  separate(classification, c('d','p','c','o','f','g','s'), sep = ';') ->tax.c

rownames(tax.c) = tax$user_genome

#remove the prefix in each level, e.g., remove 'k_' in kingdom column
#. - a "dot" indicates any character
#* - means "0 or more instances of the preceding regex token"
tax.cr = as.data.frame(lapply(tax.c,function(x){sub('.*_','',x)}))
rownames(tax.c) -> rownames(tax.cr) 
#create a column that has 'family genus' as taxa names that will be binded to btpm
tax$user_genome == rownames(tax.cr) #sanity check
tax = merge(x = subset(tax,select = c(user_genome), drop = F), y =tax.cr,
            by.x = 'user_genome', by.y = 0,
            all.x = T, all.y = T)
tax$fg = paste(tax$f, tax$g, sep = ' ')
#rename the bin
tax$user_genome = sub('.orig','',tax$user_genome)
tax$user_genome = sub('.strict','',tax$user_genome)
#merge to btpm
btpm = merge(x = subset(tax, select = c(user_genome,fg)),
             y = btpm,
             by.x = 'user_genome', by.y = 'bin',
             all.y = T)

#rename sample names in btpm
names(btpm)
SID_conversion = as.data.frame(t(btpm[,-c(1,2)]))
SID_conversion$original = rownames(SID_conversion)
dim(SID_conversion)
SID_conversion = subset(SID_conversion,select = c(original),drop = F)
SID_conversion$original = sub('TPM','',SID_conversion$original)

SID_conversion = separate(SID_conversion,original,c('date','station','time','depth.watercolumn'),sep = '-')
str(SID_conversion$date)
SID_conversion$date = sub('201907','',SID_conversion$date)
SID_conversion$time = 'am'
SID_conversion$depth.watercolumn[SID_conversion$depth.watercolumn == 'TOP'] = 't'
SID_conversion$depth.watercolumn[SID_conversion$depth.watercolumn == 'BOTTOM'] = 'b'

SID_conversion$SID = paste(SID_conversion$depth.watercolumn,
                           SID_conversion$station,
                           SID_conversion$date,
                           SID_conversion$time,
                           sep = '-')
names(btpm)[c(3:ncol(btpm))] = SID_conversion$SID[match(names(btpm)[c(3:ncol(btpm))],rownames(SID_conversion))]

#make a heatmap
write.csv(btpm,'btpm.csv')
rownames(btpm) <- btpm$fg
names(btpm)
btpm = btpm[,-c(1,2)]
btpm = log10(btpm)
ComplexHeatmap::pheatmap(btpm, 
                         fontsize = 4, 
                         cluster_cols = F)

#####################analyze bin functional annotation##########
#read the ghostKOALA output (all BIN_ANNOTATION on all reassembled bins as input)
kobin = read.table('BIN_ANNOTATION/ko.all.bin.prokka.txt', sep = '\t', header = T, fill = T)
#read the key KOs used in 16s analysis
keyko = read.csv('/Volumes/microbiome/rock_creek_anlysis/yue_rockcreek_16s_seq1n2_analysis/kegg_key_metabolic_processes.csv',
                 header = T, row.names = 1)

#parse keyko
keyko$KO_description = paste(keyko$KO,keyko$KO_description,sep = ' ')
#remove EC to shorten the KO_description
keyko$KO_description = gsub("\\[.+?\\]", "", keyko$KO_description)
#remove the whitespace at the end of some cells
keyko$KO_description = str_trim(keyko$KO_description,side = 'right')
keyko.complete = keyko
#remove the duplicate rows (some KO belongs to multiple metabolism e.g. pmo-amo), and remove some columns
keyko = distinct(subset(keyko, select = c(KO, KO_description)))

#subset the kobin file to only the key KOs
keykobin = subset(kobin, KO %in% keyko$KO)

#read in the file that match locus ID to bin
lcb = read.csv('BIN_ANNOTATION/match_locusID_to_bin.txt',sep = '\t', header = T, row.names = 1)
lcb$bin = sub('.strict.faa', '', lcb$bin)
lcb$bin = sub('.orig.faa', '', lcb$bin)
unique(lcb$bin) #sanity check
lcb$contig = sub('>', '', lcb$contig)
lcb$contig = sub(' .*','',lcb$contig)

#match locus to bin
keykobin = merge(x = lcb, y = keykobin,
                 by = 'contig',
                 all.y = T)
keykobin = keykobin[,-1]
#remove duplicate rows
keykobin = distinct(keykobin)

#unstack the keykobin to a df with rowname as KO, colname as bin, value as 1 if present and 0 otherwise
keykobin = as.data.frame(lapply(keykobin,as.factor))
keykobin$val = 1
keykobin$val = as.integer(keykobin$val)
str(keykobin)
keykobin.usta = as.data.frame(pivot_wider(keykobin, names_from = bin, values_from = val, values_fill = 0))

#add KO info in the table
keykobin.usta =  merge(x = keykobin.usta, y = keyko,
                       by='KO', all.x = T)
rownames(keykobin.usta) = keykobin.usta$KO_description
keykobin.usta = subset(keykobin.usta,select = -c(KO,KO_description))
#order the KOs based on the metabolism it belongs to
keyko.complete %>%
  subset(select = c(KO_description,metabolism), keyko.complete$KO_description %in% rownames(keykobin.usta)) %>%
  distinct ->keyko.order
rownames(keykobin.usta) = factor(rownames(keykobin.usta), levels = keyko.order$KO_description)
#reorder the columns
keykobin.usta = keykobin.usta[,c('bin.1','bin.2','bin.3','bin.4','bin.5',
                                               'bin.6','bin.7','bin.8','bin.9','bin.10',
                                               'bin.11','bin.12','bin.13')]
#make a heatmap
#create annotation color dataframe
annot.row = subset(keyko.complete, select = c(metabolism,KO_description), keyko.complete$KO_description %in% rownames(keykobin.usta))
annot.row = as.data.frame(lapply(annot.row,as.factor))
annot.row = distinct(annot.row)
rownames(annot.row) = annot.row$KO_description
annot.row = subset(annot.row, select = metabolism,drop = F)
ComplexHeatmap::pheatmap(keykobin.usta,
                         fontsize = 5,
                         cluster_cols =F,
                         cluster_rows = F,
                         annotation_row = annot.row)
