#!/bin/sh
#SBATCH
#SBATCH --job-name=gtdbtk
#SBATCH --time=6:00:00
#SBATCH --nodes=1
#SBATCH --partition=lrgmem
#SBATCH --ntasks-per-node=48

#gtdb-tk is installed in a python 3.7.7 virtual environment
ml python/3.7.7
source /home-4/yzhan231@jhu.edu/work/yuezhang/lib/GTDB-Tk/gtdbtk/bin/activate
export GTDBTK_DATA_PATH=/home-4/yzhan231@jhu.edu/work/yuezhang/lib/GTDB-Tk/release207
ml fastANI

IN=../REASSEMBLY/reassembled_bins
OUT=../BIN_CLASSIFICATION_gtdbtk

rm -r ${OUT}/*

gtdbtk classify_wf --genome_dir $IN  --out_dir $OUT  --cpus 48 --tmpdir ../TMPDIR/tmpdir --full_tree --force 



