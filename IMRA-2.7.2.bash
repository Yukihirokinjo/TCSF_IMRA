#!/bin/bash
#
##IMRA.bash
#

version="2.7.2"

echo "Location of TCSF_IMRA: ${TCSF_IMRA}"
[ -z "${TCSF_IMRA}" ] && echo "[Error] The environment variable TCSF_IMRA is not set." &&  exit 1

Rlib=${TCSF_IMRA%/*}/Rlib

##Functions

usage_exit() {
	echo "Usage: IMRA-${version}.bash -ref <Reference_Contigs> -inF <input_Reads_1>  -inR <input_Reads_2>  < Options.. >" 1>&2
	exit 1
}

getseq() {
	i=$1
	end=$2
	while [ "$i" -le "$end" ];do
		echo "$i"
		i=`expr "$i" + 1`
	done
}

Error_Check() {
    if [ "$?" -ne 0 ]; then
      echo "[Error] $1 failed. Please check the Messages above" 1>&2
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
		'-ref')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2" ]; then
					ref_contigs="$2" 
					shift 2
				else
					echo " File $2 is not found " 1>&2
					exit 1
				fi
			fi
			;;
		'-inF')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2"   ]; then
					input_fastq_F="$2" 
					shift 2
				else
					echo " File $2 is not found " 1>&2
					exit 1
				fi
			fi
			;;
		'-inR')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ -e "$2"  ]; then
					input_fastq_R="$2" 
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
					exit 1
				fi
			fi
			;;
		'-n')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					num_cycle="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-l')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ] && [ $2 -ge 100 ]; then
					largeC="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer (>100) " 1>&2
					exit 1
				fi
			fi
			;;
		'-c')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
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
                '-e')
                        if [ -z "$2" ]; then
                                echo "PROGRAM: option requires an argument $1" 1>&2
                                exit 1
                        else
                                if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
                                        Edepth="$2"
                                        shift 2
                                else
                                        echo " Argument with option $1 should be an integer " 1>&2
                                        exit 1
                                fi
                        fi
                        ;;
		'-slA')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					sl_A="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-ssA')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					ss_A="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-scA')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					sc_A="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-mlA')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					min_ol_A="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-miA')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					min_id_A="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer " 1>&2
					exit 1
				fi
			fi
			;;
		'-trim')
			if [ -z "$2" ]; then
				echo "PROGRAM: option requires an argument $1" 1>&2
				exit 1
			else
				if  [ `expr "$2" : "[0-9]*$"` -gt 0  ]; then
					TrimProp="$2" 
					shift 2
				else
					echo " Argument with option $1 should be an integer (1-99)" 1>&2
					exit 1
				fi
			fi
			;;
		'-Large')
			LargeComp="on"
			shift 1
			;;
		'-infoA')
			info_A="on"
			shift 1
			;;
		'-spa')
			SPAdes="on"
			shift 1
			;;
		'-454')
			Newbler="on"
			shift 1
			;;
		'-idba')
			IDBA="on"
			shift 1
			;;
		'-sensitive')
			MapMode="sensitive"
			shift 1
			;;
                '-k')
                        if [ -z "$2" ]; then
                                echo "PROGRAM: option requires an argument $1" 1>&2
                                exit 1
                        else
                                Kmers="$2"
                                shift 2
                        fi
                        ;;
		*)
		echo "Invalid option $1 " 1>&2
		usage_exit
		;;
	esac
done


[ -z "$ref_contigs" ] && usage_exit

[ -z "$input_fastq_F" ] && usage_exit

[ -z "$input_fastq_R" ] && usage_exit

[ -z "$MapMode" ] && MapMode="Accurate"

#Set default output directory

[ -z "$out_dir" ] && out_dir="IMRA_OUT_`date +%Y%m%d`_`date +%H%M`"

#Set Assembler (default: SPAdes)

if [ "$Newbler" = "on" ]; then
  Assembler=Newbler
elif [ "$IDBA" = "on" ]; then
  Assembler=IDBA-UD
else
  Assembler=SPAdes
fi

mkdir -p ${out_dir}/Reads/
mkdir -p ${out_dir}/IDs/
mkdir -p ${out_dir}/Contigs/
mkdir -p ${out_dir}/Map/
mkdir -p ${out_dir}/EstInsSize/

printf  "\nIMRA--------------------------------------------------------Start.`date +%Y%m%d%H%M%S`\n"


##---------------------------------------------------------------Initial status

echo "## RunName: ${out_dir}" > ${out_dir}/Result.log
echo "## Date: `date +%Y/%m/%d/%H:%M:%S`" >> ${out_dir}/Result.log
echo "## Reference: ${ref_contigs}" >> ${out_dir}/Result.log
echo "## InputReads: $input_fastq_F, $input_fastq_R" >> ${out_dir}/Result.log
echo "## Assembler: ${Assembler}" >> ${out_dir}/Result.log
echo "## Parameters:" >> ${out_dir}/Result.log

if [ "$Assembler" != "Newbler" ]; then
  echo "# K-mers: ${Kmers:=33,55,77,91}" >> ${out_dir}/Result.log
else
  echo "# min_ol_A = ${min_ol_A:=40}" >> ${out_dir}/Result.log
  echo "# min_id_A = ${min_id_A:=90}" >> ${out_dir}/Result.log
  echo "# Exp_Depth = ${Edepth:=0}" >> ${out_dir}/Result.log
  echo "# Seed_Len_A = ${sl_M:=16}" >> ${out_dir}/Result.log
  echo "# Seed_Stp_A = ${ss_M:=12}" >> ${out_dir}/Result.log
  echo "# Seed_Cnt_A = ${sc_M:=1}" >> ${out_dir}/Result.log
  echo "# Seed_Len_A = ${sl_A:=16}" >> ${out_dir}/Result.log
fi

echo "" >> ${out_dir}/Result.log
echo "## Run results:" >> ${out_dir}/Result.log


# Get initial assembly status
printf "\n\n-----------Initial status\n\n\n"

R --vanilla --slave --args ${out_dir} Initial ${ref_contigs} ${Rlib} < $(which AssemblyEval.R)
Error_Check AssemblyEval.R

cat   ${out_dir}/tmp_Result.log >> ${out_dir}/Result.log

## build reference INDEX and check Insert size
bowtie2-build -f $ref_contigs ${out_dir}/Map/tmp_BT2 > ${out_dir}/EstInsSize/BT2build.log
Error_Check bowtie2-build

seqtk sample -s100 ${input_fastq_F} 0.1 > ${out_dir}/EstInsSize/tmp_subread_F.fastq
seqtk sample -s100 ${input_fastq_R} 0.1 > ${out_dir}/EstInsSize/tmp_subread_R.fastq
Error_Check seqtk

if [ ${MapMode} == "sensitive" ]; then
  bowtie2 -x ${out_dir}/Map/tmp_BT2 -1 ${out_dir}/EstInsSize/tmp_subread_F.fastq  -2 ${out_dir}/EstInsSize/tmp_subread_R.fastq \
        -S ${out_dir}/EstInsSize/subBT2.sam  \
        -I 100 -X 1000 -p ${cpu:=1} --very-fast --no-mixed  --no-discordant --ignore-quals \
        2> ${out_dir}/EstInsSize/BT2map.log
else
  bowtie2 -x ${out_dir}/Map/tmp_BT2 -1 ${out_dir}/EstInsSize/tmp_subread_F.fastq  -2 ${out_dir}/EstInsSize/tmp_subread_R.fastq \
        -S ${out_dir}/EstInsSize/subBT2.sam  -5 10 -3 10 \
        -I 100 -X 1000 -p ${cpu:=1} --score-min L,0,-0.1  -5 5 -3 10 -D 5 -R 1 -N 0 -L 30 -i S,0,2.5 \
        --no-mixed  --no-discordant --ignore-quals 2> ${out_dir}/EstInsSize/BT2map.log
fi

Error_Check bowtie2

grep "overall alignment rate" ${out_dir}/EstInsSize/BT2map.log


rm ${out_dir}/EstInsSize/tmp_subread_*.fastq

# select uniquely mapped reads
grep -v "XS:" ${out_dir}/EstInsSize/subBT2.sam > ${out_dir}/EstInsSize/subBT2.unique.sam

samtools stats ${out_dir}/EstInsSize/subBT2.unique.sam > ${out_dir}/EstInsSize/SamStat.txt
Error_Check samtools
grep ^SN ${out_dir}/EstInsSize/SamStat.txt  | cut -f 2-  > ${out_dir}/EstInsSize/SamStatSN.txt

# Set library information (insert size, read length, etc.) 
InsSizeT=`grep "insert size average" ${out_dir}/EstInsSize/SamStatSN.txt | cut -f 2 `
InsSize=${InsSizeT%.*}
InsDevT=`grep "insert size standard deviation" ${out_dir}/EstInsSize/SamStatSN.txt | cut -f 2`
InsDev=${InsDevT%.*}
ReadLen=`grep "average length:" ${out_dir}/EstInsSize/SamStatSN.txt | cut -f 2`
minInsSize=$(( InsSize - 3*InsDev - 10 ))
maxInsSize=$(( InsSize + 3*InsDev + 10 ))
if [ ${minInsSize} -lt 50  ]; then
 minInsSize=50
fi
if [ ${maxInsSize} -gt 1000  ]; then
 maxInsSize=1000
fi

# Trim 3'end for mapping (default: 20% of read length)
Trim=${TrimProp:=20}
TrimPT=$(( ReadLen * Trim / 100 ))
TrimP=${TrimPT%.*}

# delete sam files
rm ${out_dir}/EstInsSize/*.sam

##-------------------------------------------------------------------------Iteration start
for num in `getseq 1 ${num_cycle:-10}`
do

  mkdir -p ${out_dir}/Map/${num}/
  mkdir -p ${out_dir}/Assembly/${num}/

  printf "\nIMRA--------------------------------------------------------Cycle_${num} START\n\n"

##---------------------------------------------------------------Mapping

#------------------------------------------Set Map Reference

  # 1st iteation

  if [ ${num} = 1 ]; then
    if [ ${MapMode} == "sensitive" ]; then
      bowtie2 -x ${out_dir}/Map/tmp_BT2 -1 $input_fastq_F  -2 $input_fastq_R  \
        -S ${out_dir}/Map/${num}/ref.sam  -p ${cpu:=1} -I ${minInsSize} -X ${maxInsSize}   \
        --no-discordant --ignore-quals --very-fast  2> ${out_dir}/Map/${num}/BT2map.log    
      Error_Check bowtie2
    else
      bowtie2 -x ${out_dir}/Map/tmp_BT2 -1 $input_fastq_F  -2 $input_fastq_R  \
        -S ${out_dir}/Map/${num}/ref.sam  -p ${cpu:=1} -I ${minInsSize} -X ${maxInsSize}   \
        --no-discordant  -5 ${TrimP} -3 ${TrimP} --ignore-quals \
        --score-min L,0,-0.05  -D 5 -R 1 -N 0 -L 30 -i S,0,2.5  2> ${out_dir}/Map/${num}/BT2map.log
      Error_Check bowtie2
    fi
  else

    R --vanilla --slave --args $ref_contigs ${Rlib} < $(which ContigsEdgeExtract.R)  # >2nd iteration -> Contigs edge extraction
    Error_Check ContigsEdgeExtract.R
    cat tmp_ContigsEdge.fasta > ${out_dir}/Map/${num}/ContigsEdge_${num}.fasta
    rm  tmp_ContigsEdge.fasta

    bowtie2-build -f ${out_dir}/Map/${num}/ContigsEdge_${num}.fasta ${out_dir}/Map/${num}/ref_BT2 \
                  > ${out_dir}/Map/${num}/BT2build.log
    Error_Check bowtie2-build

    bowtie2 -x ${out_dir}/Map/${num}/ref_BT2 -1 $input_fastq_F  -2 $input_fastq_R  \
        -S ${out_dir}/Map/${num}/ref.sam  -p ${cpu:=1} -I ${minInsSize} -X ${maxInsSize}    \
        --no-discordant  -5 ${TrimP} -3 ${TrimP} --ignore-quals \
        --score-min L,0,-0.05  -D 5 -R 1 -N 0 -L 30 -i S,0,2.5  2> ${out_dir}/Map/${num}/BT2map.log 
    Error_Check bowtie2
  fi

  grep "overall alignment rate"  ${out_dir}/Map/${num}/BT2map.log

##---------------------------------------------------------------Read selection
# both correctly mapped: 194
# one correctly mapped: 
  samtools view -S -F4  ${out_dir}/Map/${num}/ref.sam > ${out_dir}/Map/${num}/mapped.sam
  Error_Check samtools
  cut -f1 ${out_dir}/Map/${num}/mapped.sam | sort | uniq > ${out_dir}/Map/${num}/mapped.list

  if [ ${num} = 1 ]; then
    cat ${out_dir}/Map/${num}/mapped.list | sort | uniq > ${out_dir}/IDs/selected_ID_${num}.txt
  else
    cat ${out_dir}/Map/${num}/mapped.list | sort | uniq > ${out_dir}/IDs/add_selected_ID_${num}.txt
    cat ${out_dir}/IDs/selected_ID_$((num - 1)).txt ${out_dir}/IDs/add_selected_ID_${num}.txt \
      | sort | uniq > ${out_dir}/IDs/selected_ID_${num}.txt
  fi

  if [ "$?" -ne 0 ] || [ ! -s "${out_dir}/IDs/selected_ID_${num}.txt" ]; then
    echo "[Error] Can not read ${num}_mapped.list. Please check the File (Read ID would be wrong)." 1>&2
    exit 1
  fi

  #Check read type 
  CASAVAold=$(head -n 1 $input_fastq_F  | awk '{print $1}' | grep -c "/1$")
  if [ "${CASAVAold}" == "0" ]; then
    CASAVAtype="new"
    printf "\nread type: >= Casava ver. 1.8 \n"
    awk ' {print $0 }' ${out_dir}/IDs/selected_ID_${num}.txt > ${out_dir}/IDs/selected_ID_F_${num}.txt
    awk ' {print $0 }' ${out_dir}/IDs/selected_ID_${num}.txt > ${out_dir}/IDs/selected_ID_R_${num}.txt
  else
    CASAVAtype="old"
    printf "\nread type: < Casava ver. 1.8 \n"
    awk ' {print $0 "/1" }' ${out_dir}/IDs/selected_ID_${num}.txt > ${out_dir}/IDs/selected_ID_F_${num}.txt
    awk ' {print $0 "/2" }' ${out_dir}/IDs/selected_ID_${num}.txt > ${out_dir}/IDs/selected_ID_R_${num}.txt
  fi

  seqtk  subseq  $input_fastq_F  ${out_dir}/IDs/selected_ID_F_${num}.txt > ${out_dir}/Reads/${CASAVAtype}_selected_reads_F_${num}.fastq
  seqtk  subseq  $input_fastq_R  ${out_dir}/IDs/selected_ID_R_${num}.txt > ${out_dir}/Reads/${CASAVAtype}_selected_reads_R_${num}.fastq
  Error_Check seqtk


  if  [ ! -s "${out_dir}/Reads/${CASAVAtype}_selected_reads_F_${num}.fastq" ] || [ ! -s "${out_dir}/Reads/${CASAVAtype}_selected_reads_R_${num}.fastq" ] ; then
    echo "[Error] seqtk failed. Please check the the File." 1>&2
    id_len=`cat ${out_dir}/IDs/selected_ID_${num}.txt | wc -L`
    if [ "$id_len" -ge 50 ]; then
      echo "[Error] IDs of the individual reads are too long. (It should be < 50)"
    fi
    exit 1
  else
    printf  "\nReads selection ---------------------------- Finish\n\n"
  fi

  # delete sam files
  rm ${out_dir}/Map/${num}/*.sam

#----------------------Get insert size
  # Calculate Insert Size

  #Set default -l parameter (2x of average insert size)

  [ -z "$largeC" ] && largeC=`expr ${InsSize} \* 2`
  
  printf "\n## Computed Insert Size Avg = ${InsSize} \n"
  printf "## Large Contig Threshold = ${largeC} \n\n\n"

##---------------------------------------------------------------Assembly
spaMODE="--only-assembler"
#spaMODE="--careful"

  if [ "$Newbler" = "on" ]; then    # run Newbler

    if [ "${CASAVAtype}" == "new" ]; then
      echo "Converting read type"
      Illumina_New2Old.bash -i ${out_dir}/Reads/${CASAVAtype}_selected_reads_F_${num}.fastq -o ${out_dir}/Reads/old_selected_reads_F_${num}.fastq
      Illumina_New2Old.bash -i ${out_dir}/Reads/${CASAVAtype}_selected_reads_R_${num}.fastq -o ${out_dir}/Reads/old_selected_reads_R_${num}.fastq
      Error_Check  Illumina_New2Old
    fi
    if [ "$LargeComp" = "on" ]; then
      runAssembly \
        -large \
        -scaffold -noace -force \
        -l      ${largeC:=500} \
        -e      ${Edepth:=0} \
        -cpu    ${cpu:=1} \
        -sl	${sl_A:=16} \
        -ss	${ss_A:=12} \
        -sc	${sc_A:=1} \
        -mi     ${min_id_A:=90} \
        -ml     ${min_ol_A:=40} \
        -o ${out_dir}/Assembly/${num} \
        -p ${out_dir}/Reads/old_selected_reads_F_${num}.fastq \
        -p ${out_dir}/Reads/old_selected_reads_R_${num}.fastq
      Error_Check  Assembly

      cp ${out_dir}/Assembly/${num}/454ScaffoldContigs.fna  ${out_dir}/Assembly/${num}/IMRA-Contigs.fasta
      cp ${out_dir}/Assembly/${num}/454Scaffolds.fna  ${out_dir}/Assembly/${num}/IMRA-Scaffolds.fasta
    else
  # run Newbler
      runAssembly \
        -scaffold -noace -force \
        -l      ${largeC:=500} \
        -e      ${Edepth:=0} \
        -cpu    ${cpu:=1} \
        -sl	${sl_A:=16} \
        -ss	${ss_A:=12} \
        -sc	${sc_A:=1} \
        -mi     ${min_id_A:=90} \
        -ml     ${min_ol_A:=40} \
        -o ${out_dir}/Assembly/${num} \
        -p ${out_dir}/Reads/old_selected_reads_F_${num}.fastq \
        -p ${out_dir}/Reads/old_selected_reads_R_${num}.fastq
      Error_Check  Assembly

      cp ${out_dir}/Assembly/${num}/454ScaffoldContigs.fna  ${out_dir}/Assembly/${num}/IMRA-Contigs.fasta
      cp ${out_dir}/Assembly/${num}/454Scaffolds.fna  ${out_dir}/Assembly/${num}/IMRA-Scaffolds.fasta
    fi
    if [ -z $info_A ]; then
	rm ${out_dir}/Assembly/${num}/454*Status.txt
    fi

  elif [ "$IDBA" = "on" ]; then   # run IDBA-UD

    fq2fa --merge ${out_dir}/Reads/${CASAVAtype}_selected_reads_F_${num}.fastq ${out_dir}/Reads/${CASAVAtype}_selected_reads_R_${num}.fastq ${out_dir}/Reads/${CASAVAtype}_selected_reads_${num}.fa
    Error_Check  IDBA-UD_fq2fa
    idba_ud  -r ${out_dir}/Reads/${CASAVAtype}_selected_reads_${num}.fa -o ${out_dir}/Assembly/${num} \
             --mink ${mink:=21} --maxk ${maxk:=121} --step ${step:=20}  --num_threads ${cpu:=1} --similar 0.99 --min_contig ${largeC:=1000}
    Error_Check  IDBA-UD

    cp ${out_dir}/Assembly/${num}/contig.fa   ${out_dir}/Assembly/${num}/IMRA-Contigs.fasta
    cp ${out_dir}/Assembly/${num}/scaffold.fa  ${out_dir}/Assembly/${num}/IMRA-Scaffolds.fasta

  else     # run SPAdes

    spades.py -1 ${out_dir}/Reads/${CASAVAtype}_selected_reads_F_${num}.fastq \
              -2 ${out_dir}/Reads/${CASAVAtype}_selected_reads_R_${num}.fastq \
              ${spaMODE} -o ${out_dir}/Assembly/${num} -t ${cpu:=1} -k ${Kmers:=33,55,77,91}  > ${out_dir}/Assembly/${num}/spades.log
    Error_Check  Spades

    # filter out short contigs
    grep -F ">" ${out_dir}/Assembly/${num}/contigs.fasta | sed -e 's/_/ /g' |sort -nrk 6 | \
    awk '$6>=1.0 && $4>=1000 {print $0}' | sed -e 's/ /_/g' | sed -e 's/>//g' \
      > ${out_dir}/Assembly/${num}/IMRA-Contigs.list

    grep -F ">" ${out_dir}/Assembly/${num}/scaffolds.fasta | sed -e 's/_/ /g' |sort -nrk 6 | \
    awk '$6>=1.0 && $4>=1000 {print $0}' | sed -e 's/ /_/g' | sed -e 's/>//g' \
      > ${out_dir}/Assembly/${num}/IMRA-Scaffolds.list

    seqtk  subseq  ${out_dir}/Assembly/${num}/contigs.fasta  ${out_dir}/Assembly/${num}/IMRA-Contigs.list > ${out_dir}/Assembly/${num}/IMRA-Contigs.fasta
    seqtk  subseq  ${out_dir}/Assembly/${num}/scaffolds.fasta  ${out_dir}/Assembly/${num}/IMRA-Scaffolds.list > ${out_dir}/Assembly/${num}/IMRA-Scaffolds.fasta
    Error_Check seqtk
    # delete intermediate
    rm -rf ${out_dir}/Assembly/${num}/K*

  fi

  ## delete intermediate reads
  rm ${out_dir}/Reads/${CASAVAtype}_selected_reads_F_${num}.fastq
  rm ${out_dir}/Reads/${CASAVAtype}_selected_reads_R_${num}.fastq

##---------------------------------------------------------------Assembly evaluation
  printf "\n-----------Cycle_${num} summary\n\n" 

  ref_contigs="${out_dir}/Assembly/${num}/IMRA-Contigs.fasta"

  R --vanilla --slave --args ${out_dir}  ${num} ${out_dir}/Assembly/${num}/IMRA-Scaffolds.fasta ${Rlib} <  $(which AssemblyEval.R)  
  Error_Check AssemblyEval.R

  cat ${out_dir}/tmp_Result.log >> ${out_dir}/Result.log
  rm  ${out_dir}/tmp_Result.log

#  cp ${out_dir}/Assembly/${num}/IMRA-Contigs.fasta  ${out_dir}/Contigs/Contigs_${num}.fasta
#  cp ${out_dir}/Assembly/${num}/IMRA-Scaffolds.fasta  ${out_dir}/Contigs/Scaffolds_${num}.fasta

	printf  "\nIMRA--------------------------------------------------------Cycle_${num} END.\n"

done

##-------------------------------------------------------------------------Iteration finish

##---------------------------------------------------------------Parameters


printf  "\nIMRA--------------------------------------------------------Finish.`date +%Y%m%d%H%M%S`\n"

##END OF FILE

