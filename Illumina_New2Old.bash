#!/bin/bash

## Illumina_New2Old.sh  [-i input_file] [-o output_file]

##The structure of description lane as follows
#@[unique read name]:#0/[menber of a pair (1/2)]

usage_exit() {
	echo "Usage: Illumina_New2Old.bash  [-i input_file] [-o output_file]" 1>&2
	exit 1
}

version=0.8


##Get options

while [ "$#" -gt 0 ]
do
	case "$1" in
		'-v' | '--version' )
			echo "Ver._$version" 
			exit 1
			;;
		'-h' | '--help' )
			usage_exit
			;;
		'-i')
			if  [  -e "$2"  ]; then
				input_file="$2" 
				shift 2
			else
				echo "[Error] The input file is not found" 1>&2
				exit 1	 
			fi
			;;
		'-o')
			if  [ ! -e "$2"  ]; then
				out_file="$2" 
				shift 2
			else
				echo "[Error] The output file is already exist" 1>&2	 
				exit 1	 
			fi
			;;
		*)
		echo "Invalid option "$1" " 1>&2 
		usage_exit
		;;
	esac
done

if [ -z "$input_file" ]; then
	echo "Input file is not specified" 1>&2
	usage_exit
fi
if [ -z "$out_file" ]; then
	echo "Output file is not specified" 1>&2
	usage_exit
fi

##Run

cat "$input_file" | awk '
 	{
 	if (NR % 4 == 1) 
 		{
 		split($2, arr, ":"); 
 		print $1 ":" "#" "0" "/" arr[1]
 		} 
 	else {print $0} 
 	}
 ' > "$out_file"

##Finish
