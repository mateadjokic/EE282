                  #!/bin/bash

srun -A class-ee282 --pty bash -i
conda activate ee282

cd /data/homezvol1/djokicm/classrepos/ee282/

git checkout -b homework3
git push --set-upstream origin homework3

touch homework3.md
touch hw3_genome_summary.sh
touch hw3_annotation_summary.sh

wget http://ftp.flybase.net/releases/FB2022_05/dmel_r6.48/fasta/dmel-all-chromosome-r6.48.fasta.gz

wget http://ftp.flybase.net/releases/FB2022_05/dmel_r6.48/fasta/md5sum.txt

md5sum -c <(grep all-chrom md5sum.txt)

faSize dmel-all-chromosome-r6.48.fasta.gz
