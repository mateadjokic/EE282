#!/bin/bash

srun -A class-ee282 -c 8 --pty /bin/bash -i
conda activate ee282

cd /pub/jje/ee282

cp iso1_onp_a2_1kb.fastq /dfs6/pub/djokicm/classrepos/ee282/

# Install minimap and miniasm (requiring gcc and zlib)
git clone https://github.com/lh3/minimap2 && (cd minimap2 && make)
git clone https://github.com/lh3/miniasm  && (cd miniasm  && make)

cd /dfs6/pub/djokicm/classrepos/ee282/

minimap2 -x ava-ont -t16 iso1_onp_a2_1kb.fastq{,} | gzip -1 > reads.paf.gz

miniasm -f iso1_onp_a2_1kb.fastq reads.paf.gz > reads.gfa
##maybe this {a2_1kb.fastq, reads.paf.gz} but don't need because I am doing everything in the same folder and JJ isnt

n50 () {
bioawk -c fastx ' { print length($seq); n=n+length($seq); } END { print n; } ' $1 \
| sort -rn \
| gawk ' NR ==1 { n = $1 }; NR > 1 {ni = $1 + ni; } ni/n > 0.5 { print $1; exit; } '
}

awk ' $0 ~/^S/ { print ">" $2" \n" $3 } ' reads.gfa \
| tee >(n50 /dev/stdin > n50.txt) \
| fold -w 60 \
> unitigs.fa

n50 unitigs.fa

#substitute nanopore data for the truseq in the below pipeline

#Nanopore
faSize -detailed unitigs.fa > data/processed/nanopore.unsorted.namesizes.txt

sort -rnk 2,2  data/processed/nanopore.unsorted.namesizes.txt >  data/processed/nanopore.sorted.namesizes.txt

cut -f 2 data/processed/nanopore.sorted.namesizes.txt > data/processed/chopped.txt

awk ' BEGIN { print "Assembly\tLength\nNanoPore\t0" } { print "NanoPore\t" $1 } ' /dfs6/pub/djokicm/classrepos/ee282/data/processed/chopped.txt >  data/processed/nanopore.sorted.sizes.txt

#Scaffold and contig
gunzip -c dmel-all-chromosome-r6.48.fasta.gz\
| tee >(faSize -detailed /dev/stdin \
        | sort -rnk 2,2 \
        | tee data/processed/ISO1.r6.scaff.sorted.namesizes.txt \
        | cut -f 2 \
        | awk ' BEGIN { print "Assembly\tLength\nFB_Scaff\t0" } { print "FB_Scaff\t" $1 } ' \
        > data/processed/ISO1.r6.scaff.sorted.sizes.txt) \
| faSplitByN /dev/stdin /dev/stdout 10 \
| tee >(gzip -c > data/raw/ISO1.r6.ctg.fa.gz) \
| faSize -detailed /dev/stdin \
| sort -rnk 2,2 \
| tee data/processed/ISO1.r6.ctg.sorted.namesizes.txt \
| cut -f 2 \
| awk ' BEGIN { print "Assembly\tLength\nFB_Ctg\t0" } { print "FB_Ctg\t" $1 } ' \
> data/processed/ISO1.r6.ctg.sorted.sizes.txt

# Plotting. Not necessary to clean up.
plotCDF2 /data/processed/*.sizes.txt output/figures/CDF.png


#Find buscos
busco -i unitigs.fa -l diptera_odb10 -o unitigs_busco -m genome

gunzip -c dmel-all-chromosome-r6.48.fasta.gz > dmel_gunzip.fasta.gz
busco -c 16 -i dmel_gunzip.fasta.gz -l diptera_odb10 -o FB_busco -m genome


#Extra Credit

conda install -c bioconda mummer

faSplitByN dmel-all-chromosome-r6.48.fasta.gz dmel.ctg.fa.gz 10
gzip -c dmel.ctg.fa.gz > dmel.ctg.zip.fa.gz

REF="dmel.ctg.fa.gz"
PREFIX="flybase"
SGE_TASK_ID=1
QRY=$(ls unitigs.fa | head -n $SGE_TASK_ID | tail -n 1)
PREFIX=${PREFIX}_$(basename ${QRY} .fa)

###please use a value between 75-150 for -c. The value of 1000 is too strict.
nucmer -l 100 -c 125 -d 10 -banded -D 5 -prefix ${PREFIX} ${REF} ${QRY}
mummerplot --fat --layout --filter -p ${PREFIX} ${PREFIX}.delta -R ${REF} -Q ${QRY} --png






###*DISREGARD - PERSONAL NOTE* Alternative code from class demo for pipelines

faSize -detailed dmel-all-chromosome-r6.48.fasta.gz \
| sort -k2,2rn \
| gawk ' { t=t+$2; print $2 "\t" t } END { print t } ' \
| sort -k1,1rn \
| awk '
  NR == 1 { t = $1 }
  NR > 1 { print NR-1 "\t" $0 "\t" $2 / t }
' \
|less

