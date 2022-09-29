#since GTDB-TK only takes input as .fna files, we have to remove the metawrap bin refinement output from .fa to .fna
cd ../REASSEMBLY/reassembled_bins
for i in *.fa; do
	mv $i ${i%.fa}.fna
	echo "$i is renamed to ${i%.fa}.fna"
done 


