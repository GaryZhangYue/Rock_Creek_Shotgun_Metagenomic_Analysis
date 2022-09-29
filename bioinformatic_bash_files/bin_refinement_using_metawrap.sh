#!/bin/sh
#SBATCH
#SBATCH --job-name=binrefinement
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
#SBATCH --partition=lrgmem

#export PATH="~/.conda/envs/metawrap-env/bin:$PATH"
#source ~/.bashrc

date
echo "starting bin consolidation"

ml anaconda
conda activate metawrap-env
which python

#make sure mkdir bin_refinement
OUTDIR=../BIN_REFINEMENT
O
mkdir -p $OUTDIR
IN=../BINNING

metawrap bin_refinement -o ${OUTDIR} -t 1 -A ${IN}/metabat2_bins/ -B ${IN}/maxbin2_bins/ -C $/${IN}/concoct_bins/ -c 70 -x 5

date
echo "end"

