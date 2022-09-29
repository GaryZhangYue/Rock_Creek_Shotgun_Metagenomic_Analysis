#!/bin/sh
#SBATCH
#SBATCH --job-name=salmon
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --partition=lrgmem
#SBATCH --ntasks-per-node=48

ml anaconda
conda activate salmon


LIB_DIR=../CLEAN_READS

ASSEMBLY=../BIN_REFINEMENT/metawrap_70_5_bins/all_bins_concatenated.fa

cat ../BIN_REFINEMENT/metawrap_70_5_bins/bin* > $ASSEMBLY

OUT_DIR=../SALMON/QUANT_BINS_salmon1.5.1

mkdir -p ${OUT_DIR}/assembly_index
mkdir -p ${OUT_DIR}/quants

#indexing assembly file using salmon
salmon index -p 1 -t $ASSEMBLY -i ${OUT_DIR}/assembly_index

if [[ $? -ne 0 ]] ; then error "Something went wrong with indexing the assembly. Exiting."; fi

#quantifying the number (abundance) of reads mapped back to each bin
for F in ${LIB_DIR}/*RC*_1.fastq; do
  #next line removes everyting in $F after "_" first, and then append by "_2.fastq"
  R=${F%_*}_2.fastq
  BASE=${F##*/}
  SAMPLE=${BASE%_*}
  mkdir -p ${OUT_DIR}/quants/${SAMPLE}
  salmon quant -i ${OUT_DIR}/assembly_index -l A \
	       -1 $F \
	       -2 $R \
	       -p 48 --validateMappings -o ${OUT_DIR}/quants/${SAMPLE}
  echo "${SAMPLE} processed"
done 

if [[ $? -ne 0 ]] ; then error "Something went wrong with quantifying the assembly. Exiting."; fi

#rename the output file of salmon
cd ${OUT_DIR}/quants
for i in *; do
        mv ${i}/quant.sf ./${i}_quant.sf
done
