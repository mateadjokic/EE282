#!/bin/bash

srun -A class-ee282 -c16 --pty bash -i
conda activate ee282

wget https://data.qiime2.org/distro/core/qiime2-2022.8-py38-linux-conda.yml
conda env create -n qiime2-2022.8 --file qiime2-2022.8-py38-linux-conda.yml

cd /dfs6/pub/djokicm/classrepos/ee282/Final/

touch final.md
touch final_summary.sh

#Fish files for practicing import and conversion from fastq.gz to .qza
#wget "https://drive.google.com/uc?export=download&id=10JAIE8XpUdFRJ5o3S3_wSppPaYAByCVy"
#mv uc\?export\=download\&id\=10JAIE8XpUdFRJ5o3S3_wSppPaYAByCVy barcodes.fastq.gz

#wget "https://drive.google.com/uc?export=download&id=1IKic_CHDtu3NE44riOX7JFUuk3z7wTFL"
#mv uc\?export\=download\&id\=1IKic_CHDtu3NE44riOX7JFUuk3z7wTFL forward.fastq.gz

#wget "https://drive.google.com/uc?export=download&id=1CRNmCWeO-WWIfk9cDcbtLux6n5QnEHxw"
#mv uc\?export\=download\&id\=1CRNmCWeO-WWIfk9cDcbtLux6n5QnEHxw reverse.fastq.gz

#wget "https://drive.google.com/uc?export=download&id=1_XwDhA6A9yItlPt2fv3QVbmGWzGBdvpp"
#mv uc\?export\=download\&id\=1_XwDhA6A9yItlPt2fv3QVbmGWzGBdvpp Metadata_file.txt

#wget "https://drive.google.com/uc?export=download&id=1tbv6w-SGTahO5fTaHyO4g19XfE0Itrbb"
#mv uc\?export\=download\&id\=1tbv6w-SGTahO5fTaHyO4g19XfE0Itrbb metadata.txt

#wget Google Drive files formatting were all messed up - needed to download from Drive to remote machine and transfer from remote machine.

mkdir emp-paired-end-sequences

#activate qiime2

conda activate qiime2-2022.8

#importing files into qiime
qiime tools import \
  --type EMPPairedEndSequences \
  --input-path emp-paired-end-sequences \
  --output-path emp-paired-end-sequences.qza
  

#demultiplex sequenceQ
qiime demux emp-paired \
--i-seqs emp-paired-end-sequences.qza \
--m-barcodes-file metadata.txt \
--m-barcodes-column barcodes \
--p-no-golay-error-correction \ #added this because I was getting an error with barcode orientation and no sequences mapped to samples
--o-per-sample-sequences demux-paired-end.qza \
--o-error-correction-details demux-paired-details.qza

#Summarize sequences
qiime demux summarize \
--i-data demux-paired-end.qza \
--o-visualization demux-paired-end.qzv \

#clean up the sequences
qiime dada2 denoise-paired \
--i-demultiplexed-seqs demux-paired-end.qza \
--p-trim-left-f 114 \
--p-trim-left-r 26 \
--p-trunc-len-f 299 \
--p-trunc-len-r 246 \
--o-representative-sequences rep-seqs-dada2.qza \
--o-table feat-table.qza \
--o-denoising-stats denoising-stats.qza \
--p-n-threads 32 #designating how many threads we want used

#rename some files
mv rep-seqs-dada2.qza rep-seqs.qza
mv table-dada2.qza table.qza

#build phylogenetic tree for phylogenetic diversity - used later for alpha and beta diversity
qiime phylogeny align-to-tree-mafft-fasttree \
--i-sequences rep-seqs.qza \
--o-alignment aligned-rep-seqs.qza \
--o-masked-alignment masked-aligned-rep-seqs.qza \
--o-tree untrooted-tree.qza \
--o-rooted-tree rooted-tree.qza

#build classifier - using green genes because it should run faster
qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza
  
#Filtering sequences
qiime taxa filter-table \
--i-table feat-table.qza \
--i-taxonomy taxonomy.qza \
--p-include p__ \
--o-filtered-table table-with-phyla.qza
  
  
#filter data so that only fish instestinal content samples are included
qiime feature-table filter-samples \
--i-table table-with-phyla.qza \
--m-metadata-file metadata.txt \
--p-where "Diet='wild' AND Source ='FHL' AND Type='intestine'" \
--o-filtered-table wild-intestine-FHL-filtered-table.qza

qiime feature-table summarize \
--i-table wild-intestine-FHL-filtered-table.qza \
--o-visualization wild-intestine-FHL-filtered-table.qza \
--m-sample-metadata-file metadata.txt

#Rarefaction: choose max depth for alpha rarefaction around median frequency from table.qzv
qiime diversity alpha-rarefaction \
  --i-table wild-intestine-FHL-filtered-table.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth 4111 \
  --m-metadata-file metadata.txt \
  --o-visualization wild-intestine-FHL-filtered-alpha-rarefaction.qzv 

#Now check out alpha and beta diversity
qiime diversity core-metrics-phylogenetic \
--i-phylogeny rooted-tree.qza \
--i-table wild-intestine-FHL-filtered-table.qza \
--p-sampling-depth 1776 \
--m-metadata-file metadata.txt \
--output-dir core-metrics-results

#Alpha diversity - need to reference the Shannon's diversity index (in core metrics folder created in above)
qiime diversity alpha-group-significance \
--i-alpha-diversity core-metrics-results/shannon_vector.qza \
--m-metadata-file metadata.txt \
--o-visualization core-metrics-results/shannon_vector_significance.qzv

#Beta diversity - Bray Curtis - can't run for some reason as it is.
qiime diversity beta-group-significance \
--i-distance-matrix core-metrics-results/bray_curtis_distance_matrix.qza \
--m-metadata-file metadata.txt \
--m-metadata-column Species \
--o-visualization core-metrics-results/bray_curtis_species_significance.qza \
--p-pairwise

#######LEFT OFF RERUNNING HERE
#alternate path because we can't do bray curtis

qiime diversity alpha-rarefaction \
--i-table table-with-phyla.qza \
--i-phylogeny rooted-tree.qza \
--p-max-depth 4111 \
--m-metadata-file metadata.txt \
--o-visualization all-alpha-rarefaction.qzv
  
qiime diversity core-metrics-phylogenetic \
--i-phylogeny rooted-tree.qza \
--i-table table-with-phyla.qza \
--p-sampling-depth 917 \
--m-metadata-file metadata.txt \
--output-dir all-core-metrics-results

qiime diversity alpha-group-significance \
--i-alpha-diversity all-core-metrics-results/shannon_vector.qza \
--m-metadata-file metadata.txt \
--o-visualization all-core-metrics-results/shannon_vector_significance.qzv

qiime diversity beta-group-significance \
--i-distance-matrix all-core-metrics-results/bray_curtis_distance_matrix.qza \
--m-metadata-file metadata.txt \
--m-metadata-column Species \
--o-visualization all-core-metrics-results/bray_curtis_species_significance.qza \
--p-pairwise

