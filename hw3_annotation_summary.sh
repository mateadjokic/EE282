#!/bin/bash

srun -A class-ee282 --pty bash -i
conda activate ee282

cd /data/homezvol1/djokicm/classrepos/ee282/

git push --set-upstream origin homework3

wget https://ftp.flybase.net/releases/FB2022_05/dmel_r6.48/gtf/dmel-all-r6.48.gtf.gz

wget https://ftp.flybase.net/releases/FB2022_05/dmel_r6.48/gtf/md5sum.txt

md5sum -c <(grep dmel md5sum.txt)

bioawk -c gff '{print$feature}' dmel-all-r6.48.gtf.gz | sort | uniq -c | sort -k1n

bioawk -c gff ' $feature == "gene" {print$seqname}' dmel-all-r6.48.gtf.gz \
| sort | uniq -c | sort \
| grep -P '(X)|(Y)|(2L)|(2R)|(3L)|(3R)|(\b4\b)'
