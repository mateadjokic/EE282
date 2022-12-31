# Final Project Report - EE282 - Djokic

## Justification
The purpose of this project was to write and carry out a workflow that could be applied to my investigation of how pollution affects the gut microbial diversity of mosquitofish in Orange County. Initially, I planned to utilize previously collected abalone data from my lab but the raw 16S files were no longer available. Thererfore, I utilized a different available dataset from my lab.

## Methods
### Data Collection

Data for this project were collected and shared by Michelle Herrera who gave consent for the data to be used in this project. The dataset consists of 16S raw sequencing data from intestinal contents from multiple species of prickleback fishes. 

### Qiime2 Workflow

Raw sequence data was imported into QIIME2 and demultiplexed using the  `qimme demux emp-paired` function with a Golay error correction enabled using `--p-no-golay-error-correction`. Demultiplexed data were visualized with `qiime demux summarize` to inform appropriate cleaning, denoising, and trimming of the data. A phylogenetic tree was used to prepare for alpha diversity tests using `qiime phylogeny align-to-tree-mafft-fasttree`. A classifier was built on the Greengenes database using `qiime feature-classifier classify-sklearn`. Sequences were then filtered using `qiime taxa filter-table` and `qiime filter-table filter-samples` to include only intestinal content samples. An alpha rarefaction curve was created to visualize species richness and diversity present in gut samples using `qiime diversity alpha-rarefaction`. Finally, Shannon's diversity index was used to investigate alpha diversity in the intestinal samples using `qiime diversity alpha-group-significance`. Although proposed in the data analysis proposal, beta diversity was not calculated because of insufficient sample sizes (e.g., two groups only had one individual). Despite being unable to calculate beta diversity, I simulated an NMDS plot with the available data to practice running the code in R.

## Results

![Figure 1: Quality profiles for the forward reads.](https://github.com/mateadjokic/ee282/blob/final_project/Final/figures/ForwardReadQuality.png?raw=true)

**Figure 1: Quality profiles for forward reads.**

![Figure 2: Quality profiles for reverse reads](https://github.com/mateadjokic/ee282/blob/final_project/Final/figures/ReverseReadQuality.png?raw=true)

**Figure 2: Quality profiles for reverse reads.**

![Figure 3: Alpha rarefaction of observed features for species sampled](https://github.com/mateadjokic/ee282/blob/final_project/Final/figures/AlphaRarefactionObserved.png?raw=true)

**Figure 3: Alpha rarefaction of observed features for species sampled.**

Alpha diversity results from the Shannon diversity index are inconclusive because of low sample size, though species Pc and Xa overlap with the results from species Ap population.

![Figure 4: Alpha diversity boxplot using Shannon diversity index](https://github.com/mateadjokic/ee282/blob/final_project/Final/figures/AlphaDiversityPlot.png?raw=true)

**Figure 4: Alpha diversity boxplot using Shannon diversity index.**

![Figure 5: NMDS Plot practice](https://github.com/mateadjokic/ee282/blob/final_project/Final/figures/NMDSPlot.png?raw=true)

**Figure 5: Practice rudimentary NMDS plot.**

## Discussion

Forward read quality (Figure 1) was generally good while reverse read quality dropped off at around 246 reads (Figure 2). This drop off in read quality required cleaning and trimming of the data prior to analysis, restricting the sample size and, consequently, my ability to run beta diversity tests. According to the alpha rarefaction curve (Figure 3), it is possible that the Ap samples were not sequenced to a sufficient depth as there is potential evidence that the curve has not yet reached a plateau as it has for Pc and Xa. Lastly, the Shannon diversity index is inconclusive in this project as sample sizes were too small within two species to effectively calculate mean species diversity. The NMDS plot is largely uninterpretable because of low sample size. However, it does seem that the one species with a sample size greater than one individiual did group together. It is possible that the cleaning and trimming of the data was too aggressive and removed samples prematurely from the dataset, reducing sample size irreconcilably. Therefore, if capturing additional individuals is not possible, it may be pertinent to investigate a more relaxed approach to cleaning to potentially increase sample size. 

I have effectively written and troubleshot a workflow that has allowed me to work through a preliminary dataset in a way that is similar to my proposed analyses for my project. I am now relatively comfortable with QIIME2 and its capabilities.

Prior to entering this class, I had no experience working in a shared-computing cluster like HPC3, a remote desktop like MobaXterm, or a shell like Bash. I never programmed in Unix and had never used GitHub. In this final project, I effectively utilized MobaXterm to write and run code in Bash on HPC3 and shared these results via GitHub. 

