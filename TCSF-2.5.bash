#!/bin/bash
#
##TCSF.bash
#

version="2.5"

##Functions

usage_exit() {
	echo "Usage: TCSF.bash [-i input_contigs] [-refB reference_bacterial_genome] < Options.. >" 1>&2
	exit 1
}

Error_Check() {
    if [ "$?" -ne 0 ]; then
      echo "[Error] $1 failed. Please check the Messages avobe" 1>&2
      exit 1
    fi
}


##---------------------------------------------------------------Get options

while [ "$#" -gt 0 ]
do
	case "$1" in
		'-v' | '-version' )
			echo "$version"
			exit 1
			;;
		'-h' | '-help' )
			usage_exit
			;;
		'-i')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2" ]; then
					in_contigs="$2"
					shift 2
				else
					echo " File $2 is not found " 1>&2
					exit 1
				fi
			fi
			;;
		'-refB')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2"   ]; then
					ref_B="$2"
					shift 2
				else
					echo " File $2 is not found " 1>&2
					exit 1
				fi
			fi
			;;
		'-refM')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2"   ]; then
					ref_M="$2"
					shift 2
				else
					echo " File $2 is not found " 1>&2
					exit 1
				fi
			fi
			;;
		'-refR')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2"   ]; then
					ref_R="$2"
					shift 2
				else
					echo " File $2 is not found " 1>&2
					exit 1
				fi
			fi
			;;
		'-o')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ ! -e "$2"  ]; then
					out_dir="$2"
					shift 2
				elif [ -e "$2" ] || [ -d "$2" ]; then
					echo "The specified output directory is already exist"
						echo -n 'Overwrite ? [y/n]: '
						read ans
							case $ans in
								y)
									rm -r ./"$2"
									;;
								n)
									printf "\nExit out of the IMRA\n\n"
									exit 1
									;;
								*)
									echo "Press y(yes) or n(no)"
									;;
							esac
							echo
				fi
			fi
			;;
		'-c')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument -- $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					cpu="$2"
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-w' | '-w1' )
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument -- $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					w_size="$2"
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-w2')
				if [ -z "$2" ]; then
					echo "PROGRAM: option requires an argument -- $1" 1>&2
					exit 1
				else
					if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
						w_size2="$2"
						shift 2
					else
						echo " Argument with option $1 should be an integer " 1>&2
						exit 1
					fi
				fi
				;;
		'-e1')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument -- $1" 1>&2
				exit 1
			else
				if  	[ `expr "$2" : "[0-9]*$"` -gt 0  ]		||
					[ `expr "$2" : "[1-9][eE][-+][0-9]*$"` -gt 0 ]; then
					e_val_t=$2
					shift 2
				elif	[ `echo "$2 >= 0" | bc -l` -eq 1 ]; then
					e_val_t=`echo $2 | bc -l`
					shift 2
				else
					echo " Argument with option $1 should be a positive real number " 1>&2
					exit 1
				fi
			fi
			;;
		'-e2')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument -- $1" 1>&2
				exit 1
			else
				if  	[ `expr "$2" : "[0-9]*$"` -gt 0  ]		||
					[ `expr "$2" : "[0-9][eE][-+][0-9]*$"` -gt 0 ]; then
					e_val_n=$2
					shift 2
				elif	[ `echo "$2 >= 0" | bc -l` -eq 1 ]; then
					e_val_n=`echo $2 | bc -l`
					shift 2
				else
					echo " Argument with option $1 should be a positive real number " 1>&2
					exit 1
				fi
			fi
			;;
		'-remove')
				Remv="on"
			echo "[Remove mode]"
			shift 1
			;;
		'-blaN')
			blaN="on"
			echo "[BlastN]"
			shift 1
			;;
		'-blaX')
			blaX="on"
			echo "[BlastX]"
			shift 1
			;;
		*)
		echo "Invalid option $1 " 1>&2
		usage_exit
		;;
	esac
done



[ -z "$in_contigs" ] && usage_exit

[ -z "$ref_B" ] && usage_exit



#Set default output directory

[ -z $out_dir ] && out_dir="TCSF_OUT_`date +%Y%m%d`_`date +%H%M`"

outName=${out_dir##*/} 


printf "\nTCSF--------------------------------------------------- START_`date +%Y%m%d%H%M`\n\n"


mkdir -p ${out_dir}/DB/
mkdir -p ${out_dir}/Contig_list/


cp $ref_B  ${out_dir}/DB/TCSF_DB.fna


if [ $ref_M ]; then
	cat $ref_M >> ${out_dir}/DB/TCSF_DB.fna
fi

##---------------------------------------------------------------Prepare BLAST database

if [ $blaX ]; then
     makeblastdb \
          -in		${out_dir}/DB/TCSF_DB.fna  \
          -dbtype		prot \
          -hash_index
     Error_Check MakeBlastDB
else
     makeblastdb \
          -in		${out_dir}/DB/TCSF_DB.fna  \
          -dbtype		nucl \
          -hash_index
     Error_Check MakeBlastDB
fi
##Check -refR option

if [ $ref_R ]; then
	cp $ref_R  ${out_dir}/DB/TCSF_FilterRNA.fna

	makeblastdb \
		-in		${out_dir}/DB/TCSF_FilterRNA.fna \
		-dbtype		nucl \
		-hash_index
    Error_Check MakeBlastDB
fi

##---------------------------------------------------------------1st BLAST search

printf  "\nBlast+ ---------------------------- START\n"
#collect or remove mode
if [ $Remv ]; then
## Remove mode
#Check -blaN option
  if [ $blaN ]; then
    echo "[BlastN]"
    blastn -task blastn \
      -db		${out_dir}/DB/TCSF_DB.fna  \
      -query		"$in_contigs"  \
      -evalue		${e_val_t:=1e-30}  \
      -word_size	${w_size:=11} \
      -num_threads	${cpu:=1} \
      -outfmt		6  \
      -out		${out_dir}/Contig_list/Out_BM.txt
    Error_Check BlastN

  elif [ $blaX ]; then
    echo "[BlastX]"
    blastx \
      -db		${out_dir}/DB/TCSF_DB.fna  \
      -query		"$in_contigs"  \
      -evalue		${e_val_t:=1e-30}  \
      -word_size	${w_size:=3} \
      -num_threads	${cpu:=1} \
      -outfmt		6  \
      -out		${out_dir}/Contig_list/Out_BM.txt
    Error_Check BlastX
  else
    tblastx \
      -db		${out_dir}/DB/TCSF_DB.fna  \
      -query		"$in_contigs"  \
      -evalue		${e_val_t:=1e-30}  \
      -word_size	${w_size:=3} \
      -num_threads	${cpu:=1} \
      -outfmt		6  \
      -out		${out_dir}/Contig_list/Out_BM.txt
    Error_Check tBlastX
  fi
else
## Collect mode
#Check -blaN option
  if [ $blaN ]; then
    echo "[BlastN]"
    blastn -task blastn \
      -db		${out_dir}/DB/TCSF_DB.fna  \
      -query		"$in_contigs"  \
      -evalue		${e_val_t:=1e-12}  \
      -max_target_seqs 1 \
      -max_hsps 1 \
      -word_size	${w_size:=11} \
      -num_threads	${cpu:=1} \
      -outfmt		6  \
      -out		${out_dir}/Contig_list/Out_BM.txt
    Error_Check BlastN
  elif [ $blaX ]; then
    echo "[BlastX]"
    blastx \
      -db		${out_dir}/DB/TCSF_DB.fna  \
      -query		"$in_contigs"  \
      -evalue		${e_val_t:=1e-12}  \
      -max_target_seqs 1 \
      -word_size	${w_size:=3} \
      -num_threads	${cpu:=1} \
      -outfmt		6  \
      -out		${out_dir}/Contig_list/Out_BM.txt
    Error_Check BlastX
  else
    tblastx \
      -db		${out_dir}/DB/TCSF_DB.fna  \
      -query		"$in_contigs"  \
      -evalue		${e_val_t:=1e-12}  \
      -max_target_seqs 1 \
      -word_size	${w_size:=3} \
      -num_threads	${cpu:=1} \
      -outfmt		6  \
      -out		${out_dir}/Contig_list/Out_BM.txt
    Error_Check tBlastN
  fi
echo "Blast parameters"
echo "Eval      = $eval_t"
echo "word_size = $w_size"
echo "num cpu   = $cpu"
fi

##---------------------------------------------------------------2nd BLAST search for filtration

if [ $ref_R ]; then
	blastn	-db		${out_dir}/DB/TCSF_FilterRNA.fna \
		-query		"$in_contigs"  \
		-max_target_seqs 1 \
		-evalue		${e_val_n:=1e-12} \
		-word_size	${w_size2:=11} \
		-num_threads	${cpu:=1} \
		-outfmt		6 \
		-out		${out_dir}/Contig_list/Out_R.txt
    Error_Check BlastN
fi

printf  "\nBlast+ ---------------------------- Finish\n"


##---------------------------------------------------------------Generate contig lists

printf  "\n ---------------------------- Generate Contig lists\n"

### Generate_Contig_lists
#Remove redundant hits (Measures against -max_target_seqs error)
sort -k1,1 -k12,12gr -k11,11g  ${out_dir}/Contig_list/Out_BM.txt | sort -u -k1,1  > ${out_dir}/Contig_list/Blast_out_BM.txt
rm ${out_dir}/Contig_list/Out_BM.txt

	Error_Check Generate_Contig_lists

if [ $ref_R ]; then
	sort -k1,1 -k12,12gr -k11,11g  ${out_dir}/Contig_list/Out_R.txt | sort -u -k1,1 --merge > ${out_dir}/Contig_list/Blast_out_R.txt
	rm ${out_dir}/Contig_list/Out_R.txt
	Error_Check Generate_Contig_lists
fi


#Filter out false-positive hit from 1st blast search

awk '/^>/{print $1}' $ref_B | sed -e 's/>//g' > ${out_dir}/refBnames.txt

if [ $ref_M ]; then
	awk '/^>/{print $1}' $ref_M | sed -e 's/>//g' > ${out_dir}/refMnames.txt
	while read line ; do
	awk -v name=$line '$2 == name {print $1}' ${out_dir}/Contig_list/Blast_out_BM.txt |
		sort >> ${out_dir}/Contig_list/list_B.txt
	done < ${out_dir}/refBnames.txt

	while read line ; do
	awk -v name=$line '$2 == name {print $1}' ${out_dir}/Contig_list/Blast_out_BM.txt |
		sort >> ${out_dir}/Contig_list/list_M.txt
	done < ${out_dir}/refMnames.txt
else
	while read line ; do
	awk -v name=$line '$2 == name {print $1}' ${out_dir}/Contig_list/Blast_out_BM.txt |
		sort >> ${out_dir}/Contig_list/list_B.txt
	done < ${out_dir}/refBnames.txt
#	awk '{print $1}' ${out_dir}/Contig_list/Blast_out_BM.txt > ${out_dir}/Contig_list/list_B.txt
fi
	Error_Check Generate_Contig_lists

#2nd Filtration (Optional)
if [ $ref_R ]; then
	awk NR==FNR'{data1[$1] = $1; data2[$1] = $11}
	$1 in data1{
	if(data1[$1]==$1 && data2[$1] < $11)
	print $1
	}' ${out_dir}/Contig_list/Blast_out_R.txt ${out_dir}/Contig_list/Blast_out_BM.txt > ${out_dir}/Contig_list/list_R.txt

	if [ -s "${out_dir}/Contig_list/list_R.txt" ]; then
		grep -v -f ${out_dir}/Contig_list/list_R.txt  ${out_dir}/Contig_list/list_B.txt > ${out_dir}/Contig_list/TCSF_list.txt
	else
		cat ${out_dir}/Contig_list/list_B.txt > ${out_dir}/Contig_list/TCSF_list.txt
	fi
else
	cat ${out_dir}/Contig_list/list_B.txt > ${out_dir}/Contig_list/TCSF_list.txt
fi
	Error_Check Generate_Contig_lists

#Check TCSF list file

if [ ! -s "${out_dir}/Contig_list/TCSF_list.txt" ]; then
	echo "[Error] The TCSF list file is empty. Please check the File." 1>&2
	exit 1
fi


##---------------------------------------------------------------Write fasta

printf  "\n ---------------------------- Write TCSF FASTA File\n"

seqtk subseq $in_contigs ${out_dir}/Contig_list/TCSF_list.txt > ${out_dir}/TCSF_contigs_${outName}.fna

		if [ "$?" -ne 0 ] || [ ! -s "${out_dir}/TCSF_contigs_${outName}.fna" ]; then
			echo "[Error] seqtk failed. Please check the File." 1>&2
			exit 1
		fi

##---------------------------------------------------------------QUAST evaluation

printf  "\n ---------------------------- Run Evalation\n"

  
  Rscript --vanilla --slave  `which AssemblyEval.R`  ${out_dir}  Initial  ${out_dir}/TCSF_contigs_${outName}.fna

  cat ${out_dir}/tmp_Result.log >> ${out_dir}/Result.log
  rm  ${out_dir}/tmp_Result.log


printf "\nTCSF--------------------------------------------------- Finish.`date +%Y%m%d%H%M`\n\n"
