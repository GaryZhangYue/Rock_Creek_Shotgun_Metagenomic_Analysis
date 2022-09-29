#!/usr/bin
date
echo "start all steps"
sbatch binning.sh
if [ $? -ne 0 ]; then echo "binning failed"; exit 1; fi

sbatch bin_refinement_using_metawrap.sh
if [ $? -ne 0 ]; then echo "bin refinement failed"; exit 1; fi

sbatch reassembly_using_metawrap.sh
if [ $? -ne 0 ]; then echo "reassembly failed"; exit 1; fi

sbatch classify_bins_using_metawrap.sh
if [ $? -ne 0 ]; then echo "classification failed"; exit 1; fi

sbatch annotate_bins_using_metawrap.sh
if [ $? -ne 0 ]; then echo "annotation failed"; exit 1; fi

echo "all done"
date
