#!/usr/bin/env bash

usage() {
	echo "Usage: $0 [-i <inputPath>] [-o <outputPath>] [-d] [-e <secondInput>] [-t <term>]"
	echo "Options:"
	echo " -i <inputPath>   Path to input csv file."
	echo " -o <outputPath>  Path to output file. (Default: ./subjToDept.json)"
	echo " -d               Only use this flag if you need to regenerate subjToDept.json"
	echo " -e <secondInput> Takes a second path to try and determine name/email mapping. Pass Echo csv file to i argument."
	echo " -t <term>        The term for the converted file. (e.g. Fall 2021)"
	exit 1
}

main() { 
	inputPath=""
	outputPath="./subjToDept.json"
	getDepts=false
	secondInput=""
	term=""

	while getopts ":i:o:de:t:h" opt; do
	
		case ${opt} in
			i)
				inputPath="${OPTARG}"
				;;
			o)
				outputPath="${OPTARG}"
				;;
			d)	
				getDepts=true
				;;
			e)
				secondInput="${OPTARG}"
				;;
			t)
				term="${OPTARG}"
				;;
			h)
				usage				
				;;
			\?)
				echo "Invalid option: $OPTARG"
				usage	
				;;
			:)
				echo "Option -$OPTARG requires an argument."
				usage
				;;
		esac
	done
	shift $((OPTIND -1))

	# Do something with parsed arguments for testing
	echo "Input path: $inputPath"
	echo "Output path: $outputPath"
	echo "Get departments: $getDepts"
	echo "Second input: $secondInput"
	echo "Term: $term"
}

main "$@"
