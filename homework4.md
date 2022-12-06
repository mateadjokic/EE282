# Homework 4 - EE282 - Matea Djokic

## Introduction
I created and saved two scripts ("hw4_genome_summary.sh" and 
"hw4_annotation_summary.sh") and one markdown (homework4.md) file into a new 
'Homework 4' branch in my GitHub ee282 repository. 

## Summarize Paritions of a Genome Assembly

After importing the D. melanogaster genome file from flybase.org using `wget`, the D. melanogaster genome file was subset into two files based on small (less than or equal to 100000) or large (more than 100000) sizes using `faFilter` in a conda environment.

### Calculate the following for all sequences ≤ 100kb and all sequences > 100kb:

#### 1. Total number of nucleotides

#### 2. Total number of Ns

#### 3. Total number of sequences

To calculate the total number of nucleotides, Ns, and sequences, I used `faSize`.

There were a total of 137,547,960 nucleotides, 490,385 Ns, and 7 sequences included in the large D. melanogaster sequences file.

There were a total of 6,178,042 nucleotides, 662,593 Ns, and 1,863 sequences included in the small D. melanogaster sequences file.

### Plots of the following for for all sequences ≤ 100kb and all sequences > 100kb:

#### 1. Sequence length distribution. Use a histogram! A log scale will be helpful to show the full range of lengths.

Filtered files from the previous section were exported into RStudio. In RStudio, I log transformed the data to visualize the distribution of sequence lengths for small and large sequences using the `hist()` function. Refer to the hw4_genome_summary.sh file for the R Script used.

![Figure 1: Large sequence length distribution > 100kb](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/Dmel_large_seq_length.png?raw=true)

**Figure 1: Large sequence length distribution > 100kb.**

![Figure 2: Small sequence length distribution ≤ 100kb](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/Dmel_small_seq_length.png?raw=true)

**Figure 2: Small sequence length distribution ≤ 100kb.**

#### 2. Sequence GC% distribution. Use a histogram!

To determine percent GC, `bioawk` was used and the output file was imported into R for visualization. The `hist()` function in R was used to create a histogram describing the distribution of percent GC of small and large sequences.

![Figure 3: Large sequence GC% distribution > 100kb](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/FinalGCLargeHW4.png?raw=true)

**Figure 3: Large sequence GC% distribution > 100kb.**

![Figure 4: Small sequence GC% distribution ≤ 100kb](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/FinalGCSmallHW4.png?raw=true)

**Figure 4: Small sequence GC% distribution ≤ 100kb.**

#### 3. Cumulative sequence size sorted from largest to smallest sequences.

Cumulative sequence size was visualized using the `plotCDF2` function in the conda environment. Prior to using `plotCDF2`, data were sorted from largest to smallest sequences and headers were assigned to the data using `gawk`.

![Figure 5: Cumulative sequence size for large sequences  > 100kb](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/CDFLarge.png?raw=true)

**Figure 5: Cumulative sequence size for large sequences  > 100kb.**

![Figure 6: Cumulative sequence size for small sequences ≤ 100kb](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/CDFSmallUpdated.png?raw=true)

**Figure 6: Cumulative sequence size for small sequences ≤ 100kb.**

## Genome assembly
### Assemble a genome from MinION reads

Reads were copied using `cp` while `minimap2` was used to overlap reads and `miniasm` was used to construct an assembly.

### Assembly assessment

#### 1. Calculate the N50 of your assembly.

N50 was 7910018 and was calculated from the following code.

```
n50 () {
bioawk -c fastx ' { print length($seq); n=n+length($seq); } END { print n; } ' $1 \
| sort -rn \
| gawk ' NR ==1 { n = $1 }; NR > 1 {ni = $1 + ni; } ni/n > 0.5 { print $1; exit; } '
}
```

#### 2. Compare your assembly to both the contig assembly and the scaffold assembly from the D. melanogaster on FlyBase using a contiguity plot.

I used `faSplitByN` to derive the contig assembly from the scaffold assembly from FlyBase D. melanogaster. Then I used `faSize`, `sort`, and `cut` to process the original sequence files for compatibility with `plotCDF2`. I also used `awk` to assign headers to the documents so that they would be compatible with `plotCDF2`. Lastly, I used `plotCDF2` to compare the D. melanogaster FlyBase scaffold and contig assemblies with the MinION assembly.

![Figure 7: Cumulative distribution plot for D. melanogaster contig and scaffold assembly and MinION assembly](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/CDF2.png?raw=true)

**Figure 7: Cumulative distribution plot for D. melanogaster contig and scaffold assembly and MinION assembly.**

#### 3. Calculate BUSCO scores of both assemblies and compare them.

BUSCO scores were determined on the MinION assembly and the FlyBase scaffold assembly using `busco` with the diptera_odb10 dataset.

| Field | MinION assembly | FlyBase scaffold assembly |
| ----------- | ----------- | ----------- |
| Complete BUSCOs (C) | 390 | 3243 |
| Complete and single-copy BUSCOs (S) | 390 | 3235 |
| Complete and duplicated BUSCOs (D) | 0 | 8 |
| Fragmented BUSCOs (F) | 181 | 16|
| Missing BUSCOs (M) | 2714 | 26|
| Total BUSCO groups searched | 3285 | 3285 |

Summary satistics for MinION assembly: C:11.9% [S:11.9%, D: 0.0%], F:5.5%, M:82.6%, n:3285
Summary statistics for FlyBase scaffold assembly: C: 98.7% [S:98.5%, D:0.2%], F:0.5%, M:0.8%, n:3285

The BUSCO scores identify the FlyBase scaffold assembly as having more completeness than the MinION assembly.

## Extra Credit
Compare your assembly to the contig assembly (not the scaffold assembly!) from Drosophila melanogaster on FlyBase using a dotplot constructed with MUMmer.

To recreate the contig assembly, `faSplitByN` was used to split the original FlyBase D. melanogaster scaffold assembly. Finally, the MinION assembly was compared to the D. melanogaster assembly with a dotplot made with `nucmer`, `delta-filter`, and `mummerplot` from `MUMmer`. For `nucmer`, the minimum length of a cluster of matches was set to 125, the minimum length of a single match was set to 100, and the maximum diagonal difference between anchors was 5.  For `mummerplot`, the setting was only set to display .delta alignments representing the best hit to any particular spot on either sequence.

![Figure 8: Dotplot comparison of the FlyBase D. melanogaster contig assembly and the MinION assembly.](https://github.com/mateadjokic/ee282/blob/homework4/output/figures/flybase_unitigs.png?raw=true)

**Figure 8: Dotplot comparison of the FlyBase D. melanogaster contig assembly and the MinION assembly.**
