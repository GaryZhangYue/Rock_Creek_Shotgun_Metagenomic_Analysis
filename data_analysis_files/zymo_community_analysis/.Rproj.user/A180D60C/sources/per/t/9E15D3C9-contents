require(dplyr)
require(tidyr)
require(ggplot2)
col21 <- rev(c("tomato1","darkblue","turquoise1","lightblue","darkred","mediumblue","purple","bisque","greenyellow","yellow","violetred2","darkgreen","darkgoldenrod1","deeppink3","cadetblue4","orchid2","seagreen3","purple4","dodgerblue2","red","gray27"))

#read in the salmon output
quantd = read.table('zymo-dna_quant.sf',
                header = T,
                sep = '\t')
quantc = read.table('zymo-cellular_quant.sf',
                    header = T,
                    sep = '\t')

summary(quantc$Name == quantd$Name) #sanity check
names(quantc)[4] = 'TPM_cellular'
names(quantd)[4] = 'TPM_DNA'
quant = merge(x = subset(quantc, select = c(Name, `TPM_cellular`)),
              y = subset(quantd, select = c(Name,`TPM_DNA`)),
              by = 'Name', all.x = T, all.y = T)

#read in the file that matches the name of each contig to each strain
contig = read.csv('genome_contig.csv')

#preprocess the contig names
contig$contig = sub('>','',contig$contig)
contig$contig = sub(' .*','',contig$contig)

'%nin%' = Negate('%in%')
#check why there is one contig that only appears in contig file 
contig$contig[contig$contig %nin% quant$Name]
contig[which(contig$contig == contig$contig[contig$contig %nin% quant$Name]),]
#omit this row in the following analysis

#match TPM to strain using contig names
tpm = merge(x = subset(contig, select = c(strain, contig)),
            y = quant,
            by.x = 'contig', by.y = 'Name',
            all.y = T)
tpm = tpm[,-1]
tpm = aggregate(.~strain,tpm,sum)

#input the theoretical composition for genome copy number 
tpm$theoretical_percentage = NA
tpm$theoretical_percentage = c(10.3, 0.37, 14.6, 8.5, 21.6, 13.9, 6.1, 0.57, 8.7, 15.2)
sum(tpm$theoretical_percentage)    
write.csv(tpm,'zymo.csv')
#remove the two weird strains
tpm = tpm[-c(2),]
tpm %>% mutate(DNA_percentage = TPM_DNA/sum(TPM_DNA),
               cellular_percentage = TPM_cellular/sum(TPM_cellular),
               theoretical_percentage = theoretical_percentage/sum(theoretical_percentage)) -> tpm
#stack tpm
tpm.s = gather(subset(tpm, select = c(strain,theoretical_percentage,DNA_percentage,cellular_percentage)),"type","frequency",-strain)
tpm.s$strain = sub('.fasta.*','',tpm.s$strain)
#plot
ggplot(data = tpm.s, mapping = aes(x = type, y = `frequency`,fill = strain)) +
  geom_bar(position = 'fill', stat="identity",color = 'black') +
  theme_classic() +
  scale_fill_manual(values = col21)+
  theme(legend.title = element_blank(),
        legend.position = 'bottom',
        legend.text = element_text(size = 12),
        legend.key.size = unit(0.3,'cm'),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1,size=10, color = 'black'),
        axis.text.y = element_text(size=15, color = 'black'),
        axis.title=element_text(size=18,face="bold"),
        strip.text.x = element_text(size = 15, color = "black"),
        strip.text.y = element_text(size = 15, color = "black"),
        strip.background = element_rect(color="black", fill="grey95", size=1.5, linetype="solid")) + ylab('Relative Abundance') +
  guides(fill=guide_legend(ncol=1)) +
  coord_flip()
ggsave('zymo_quality_check.png', width = 10, height = 6, device = 'png')
