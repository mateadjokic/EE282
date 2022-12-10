# Final Project Report - EE282 - Djokic

## Methods
### Data Collection

Data for this project were collected and shared by Michelle Herrera. The dataset consists of 16S raw sequencing data from intestinal contents and intestinal tissue samples from multiple species of prickleback fishes.

### Qiime2 Workflow

Raw sequence data was imported into QIIME2 and demultiplexed using the  `qimme demux emp-paired` function with a Golay error correction enabled using `--p-no-golay-error-correction`. Demultiplexed data were visualized with `qiime demux summarize` to inform appropriate cleaning, denoising, and trimming of the data. A phylogenetic tree was used to prepare for alpha diversity tests using `qiime phylogeny align-to-tree-mafft-fasttree`. A classifier was built on the Greengenes database using `qiime feature-classifier classify-sklearn`. Sequences were then filtered using `qiime taxa filter-table` and `qiime filter-table filter-samples` to include only intestinal content samples. An alpha rarefaction curve was create to visualize species richness and diversity present in gut samples using `qiime diversity alpha-rarefaction`. Finally, Shannon's diversity index was used to investigate alpha diversity in the intestinal samples using `qiime diversity alpha-group-significance`.

### R Workflow



