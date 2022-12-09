                  #!/bin/bash

srun -A class-ee282 --pty bash -i
conda activate ee282

cd /dfs6/pub/djokicm/classrepos/ee282/

git checkout -b homework4
git push --set-upstream origin homework4

touch homework4.md
touch hw4_genome_summary.sh
touch hw4_annotation_summary.sh

wget http://ftp.flybase.net/genomes/Drosophila_melanogaster/current/fasta/dmel-all-chromosome-r6.48.fasta.gz

#sequences less than 100000

infile=/data/homezvol1/djokicm/classrepos/ee282/dmel-all-chromosome-r6.48.fasta.gz
outname=/data/homezvol1/djokicm/classrepos/ee282/dmel_filtered_small
faFilter -maxSize=100000 $infile /dev/stdout \
| tee $outname.fa \
| faSize -detailed /dev/stdin \
| sort -k 2rn \
> $outname.sizes

faSize dmel_filtered_small.fa

#sequences more than 100000

infile=/data/homezvol1/djokicm/classrepos/ee282/dmel-all-chromosome-r6.48.fasta.gz
outname=/data/homezvol1/djokicm/classrepos/ee282/dmel_filtered_large
faFilter -minSize=100001 $infile /dev/stdout \
| tee $outname.fa \
| faSize -detailed /dev/stdin \
| sort -k 2rn \
> $outname.sizes

 faSize dmel_filtered_large.fa

#Getting GC%

bioawk -c fastx '{ print $name, 100*(gc($seq)) }' dmel_filtered_large.fa /dev/stdout\
>dmel_filtered_GC_large

bioawk -c fastx '{ print $name, 100*(gc($seq)) }' dmel_filtered_small.fa /dev/stdout\
>dmel_filtered_GC_small

#Plotting visualization of sequence length 
dmel_filtered_large$V2 <- as.numeric(dmel_filtered_large$V2)
hist(log(dmel_filtered_large$V2), main = "D. melanogaster large sequences",
     xlab = "Sequence length distribution", las = 1)

dmel_filtered_small$V2 <- as.numeric(dmel_filtered_small$V2)
hist(log(dmel_filtered_small$V2), main = "D. melanogaster small sequences",
     xlab = "Sequence length distribution", las = 1)

#Plotting visualization of GC%
dmel_filtered_GC_large$V2 <- as.numeric(dmel_filtered_GC_large$V2)
hist(dmel_filtered_GC_large$V2, main = "D. melanogaster large sequences",
     las = 1, xlab = "GC% Distribution")

dmel_filtered_GC_small$V2 <- as.numeric(dmel_filtered_GC_small$V2)
hist(dmel_filtered_GC_small$V2, main = "D. melanogaster small sequences",
     las = 1, xlab = "GC% Distribution")
     
#CDF plots - for large sequences

gawk 'BEGIN {print "name \t Length \t Assembly"} {print $1 "\t" $2 "\t" "Large"}' dmel_filtered_large.sizes \
>dmel_filtered_large_forCDF.txt

plotCDF2 dmel_filtered_large_forCDF.txt CDFLarge.png

#CDF plots - for small sequences

gawk 'BEGIN {print "name \t Length \t Assembly"} {print $1 "\t" $2 "\t" "Small"}' dmel_filtered_small.sizes \
>dmel_filtered_small_forCDF.txt

plotCDF2 dmel_filtered_small_forCDF.txt CDFSmall.png
