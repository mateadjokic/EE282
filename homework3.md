# Homework 3 - EE282 - Matea Djokic

## Introduction
I created and saved two scripts ("hw3_genome_summary.sh" and 
"hw3_annotation_summary.sh") and one markdown (homework3.md) file into a new 
'Homework 3' branch in my GitHub ee282 repository. 


## Question 1 - Summarize Genome Assembly

After importing the D. melanogaster genome file from flybase.org, file
integrity was verified using the md5sum command (see script file). There 
were a total of 143,726,002 nucleotides, 1,152,978 Ns, and 1870 sequences 
included in the D. melanogaster genome file. I used faSize to calculate the 
number of nucleotides, Ns, and sequences in the file.

There are 143,726,002 bases, 1,152,978 N's, and 1,870 sequences.

## Question 2 - Summarize an Annotation File

After importing the D. melanogaster annotation file from flybase.org, file 
integrity was verified using the md5sum command (see script file).

I used bioawk, sort, and uniq to sort all of the features by least to greatest 
occurrence. There are 16 feature types with exons being the most common and 
snRNAs being the least common. 

```
{
32 snRNA
    115 rRNA
    262 pre_miRNA
    300 snoRNA
    312 tRNA
    365 pseudogene
    485 miRNA
   3053 ncRNA
  17896 gene
  30799 mRNA
  30825 stop_codon
  30885 start_codon
  33738 3UTR
  46802 5UTR
 163242 CDS
 190050 exon
}
```
I then sorted the file by feature, specifying 'gene' and pulled only 
chromosome arms X, Y, 2L, 2R, 3L, 3R, and 4 using grep.

```
{ 113 Y
    114 4
   2708 X
   3489 3L
   3515 2L
   3653 2R
   4227 3R
}
```