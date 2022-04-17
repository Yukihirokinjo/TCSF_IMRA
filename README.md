#   TCSF and IMRA ver. 2.7.3


## 0. Introduction

 TCSF and IMRA are tools developed for improving de novo assembly of endosymbiont genomes.
 TCSF (TBLASTX-based Contig Selection and Filtering) selects contigs derived from your target genome by means of homology searches between denovo assembly contigs and a reference genome. It can also filter out contigs from other genomes with supplying reference sequences (such as host rRNA and mitogenomic sequences) as filters.
 IMRA (Iterative Mapping and Re-Assembling) marges and elongates a given set of contigs by mapping raw reads on them and reassembling contigs from the mapped reads. 
 It was observed that consecutive use of TCSF and IMRA improved greatly  de novo assembly of Blattabacterium genomes, endosymbionts in cockroaches, to almost their complete genomes.


## 1. Prerequisites

TCSF and IMRA depend on:

[Both]

	seqtk		(https://github.com/lh3/seqtk)
	R			ver. >3.0	

[TCSF]

	BLAST+		ver. >2.2.28 ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/

[IMRA]

	Bowtie2		ver. >2.1	(http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
	Samtools	ver. >1.4	(https://github.com/samtools/samtools)
	SPAdes		ver. >3.10	(http://cab.spbu.ru/software/spades/)

	Optional:
	IDBA-UD				(https://github.com/loneknightpy/idba)
	Newbler		ver. >2.8	(http://www.454.com/products/analysis-software/)

	Add paths for the executables of these tools to your PATH.

TCSF and IMRA work on the Linux environment. We have tested following environments:

	Ubuntu 12.04
	Ubuntu 14.0
	CentOS 5.9
	CentOS 7.1



## 2. Installation

No need to compile since TCSF and IMRA are bash wrapper scripts. Put them where you want to install them. 
In the directory, change their permissions to be executable.

```bash
git clone https://github.com/Yukihirokinjo/TCSF_IMRA.git
cd TCSF_IMRA

$ chmod u+x *.bash
$ chmod u+x *.R
```

Thereafter, add the path to your `PATH`.  
For example..
```bash
$ echo 'export PATH=/path/to/TCSF_IMRA_dir:$PATH' >> ~/.bashrc
```
An environment variable `TCSF_IMRA` is need to be set as blow.
```bash
$ echo 'export TCSF_IMRA=/path/to/TCSF_IMRA_dir' >> ~/.bashrc
```
Then, the settings above will be reflected on your current environment via `source` command.
```bash
$ source ~/.bashrc
```


## 3. Running TCSF and IMRA

### 3.1 Input data

Input contigs and reference sequences for our tools must be in fasta format. 
As input read files for IMRA, Illumina paired-end reads are assumed.  

#### IMPORTANT NOTE:
>Newbler is used as the engine of old version of IMRA (ver. 1.2). Newbler (version <=2.9) does not recognize fastq files generated by casava 1.8 or higher as paired-end reads (i.e. regarded as single-end reads). 
>You can convert such fastq files to acceptable format for IMRA by using Illumina_New2Old.bash, which is also provided as an independent script with TCSF and IMRA.  

-> Description above is not necessary in current version (ver. 2.5.4). It automatically recognizes and converts the fastq type.


### 3.2 Quick start

##### [TCSF]
```bash
$ TCSF-2.7.3.bash  -i input_contigs.fasta -refB reference_bacterial_genome.fasta
```

For closely related genome (use blastn)
```bash
$ TCSF-2.7.3.bash  -i input_contigs.fasta -refB reference_bacterial_genome.fasta -blaN
```


##### [IMRA]
```bash
$ IMRA-2.7.3.bash  -ref TCSF_contigs.fasta -inF input_read_1.fastq -inR input_read_2.fastq -spa
```

For >150bp reads
```bash
$ IMRA-2.7.3.bash  -ref TCSF_contigs.fasta -inF input_read_1.fastq -inR input_read_2.fastq -spa -k 33,55,91,121
```

For the use of reference contigs/scaffolds from a genome of closely related strain
```bash
$ IMRA-2.7.3.bash  -ref ref_contigs.fasta -inF input_read_1.fastq -inR input_read_2.fastq -spa -sensitive
```


### 3.3 Command line options
--------------------------------------------------------------------------------
##### [TCSF]  

	Mandatory:
	-i		<FILE>	Input contig file from de novo assembly.

	-refB		<FILE>	Reference bacterial genome sequence to collect target genome by first blast search.

	Optional:
	-refM		<FILE>	Reference genome sequence to filter out contaminant sequences by the first blast search (e.g. mitochondrial genome).

	-refR		<FILE>	Reference rRNA gene sequence to filter out contaminant host rRNA gene sequences by second blast search.

	-o		<str>	Output directory (default: "TCSF_OUT_<current time>).

	-c		<int>	Number of threads to be used for computation (default: 1).

	-w1		<int>	"word size" in the first blast search to collect target genome sequences by (default: tblastx, 3; blastn, 11).

	-w2		<int>	"word size" in the second blast search to filter out contaminant rRNA gene sequences by (default: 11).

	-e1		<real>	Threshold E-value in the first blast search to collect target genome sequences by (default: 1e-12).

	-e2		<real>	Threshold E-value in the second blast search to filter out contaminant rRNA gene sequences by (default: 1e-12).

	-blaN		<flag>	Use blastn in the first search instead of tblastx (default: off).


##### [IMRA]  

	Mandatory:
	-ref		<FILE>	Starting contig file (we recommend those selected by TCSF).

	-inF		<FILE>	Input read file (forward).

	-inR		<FILE>	Input read file (reverse).

	Optional:
	-spa		<flag>	Use SPAdes for iterative assembly (default).

	-idba		<flag>	Use IDBA-UD for iterative assembly.

	-454		<flag>	Use Newbler for iterative assembly.

	-sensitive	<flag>	Sensitive mode in the initial read mapping. This option is recommended if the reference contigs/scaffolds are derived from a genome of a closely related bacterial strain. 

	-o		<str>	Output directory (default: "IMRA_OUT_<current time>").

	-n		<int>	Number of iterations (default: 10).

	-l		<int>	Minimum length of contigs to be carried over to next iteration (default: twice the length of average insert size of input reads).

	-c		<int>	Number of threads to be used for computation (default: 1).

	-k		<Kmers>	K-mers for the graph assemblies (SPAdes and IDBA-UD). K-mers should be separated by comma (default: 33,55,77,91).

	-infoM		<flag>	Option for Newbler assembly. Output additional information files (e.g. ace file, status files, etc..) in the results of Mapping.

	-infoA		<flag>	Option for Newbler assembly. Output additional information files (e.g. ace file, status files, etc..) in the results of Assembly.

	-mlM		<int>	Option for Newbler assembly. Minimum overlap length in mapping phase (default: 40).

	-miM		<int>	Option for Newbler assembly. Minimum overlap identity in mapping phase (default: 90).

	-mlA		<int>	Option for Newbler assembly. Minimum overlap length in assembly phase (default: 40).

	-miA		<int>	Option for Newbler assembly. Minimum overlap identity in assembly phase (default: 90).

	-es     	<int>	Option for Newbler assembly. Estimated read depth of target contigs (default: 0).

--------------------------------------------------------------------------------

### 3.4 Output directories/files

[TCSF]
--------------------------------------------------------------------------------
	./Contig_list		:Directory contains output of each blast searches, and list of contigs as well.

	./DB			:Directory contains blast database generated by BLAST+ impremented in TCSF.

	./TCSF_contigs_xx.fna	:Output contigs file generated by TCSF.

--------------------------------------------------------------------------------

[IMRA]
--------------------------------------------------------------------------------
	./Assembly		:This directory contains Newbler assembly results in each iteration.

	./Contigs		:This directory contains output contigs/scaffolds file in each iteration.

	./Ids			:This directory contains header ids of an input reads in each iteration.

	./Map			:This directory contains Newbler mapping results in each iteration.

	./EstInsSize		:This directory contains initial mapping results to be used for insert size estimation.

	./Reads			:This directory contains input (selected) reads in each iteration.

	./Result_log.txt	:Assembly statistics in each iteration are recorded in this file.
--------------------------------------------------------------------------------


## 4. References

Kinjo Y, Saitoh S, Tokuda G. 2015. An efficient strategy developed for next-generation sequencing of endosymbiont genomes performed using crude DNA isolated from host tissues: a case study of Blattabacterium cuenoti inhabiting the fat bodies of cockroaches. Microbes Environ. 30(3):208–220.



