#!/usr/bin/env bash

getDepartments() {
	local formattedCSVPath=$1
	local outputJSONPath=$2

	# Read Echo CSV and generate JSON file which contains a mapping between subjects and departments
	# https://github.com/maroofi/csvtool

	csvtool namedcol Course\ Code,Department $formattedCSVPath | tail -n +2 | awk -F, '{
	        split($1, subjectArray, "-");
		if (!seen[subjectArray[1]]++)){
			print "\"" subjectArray[1] "\": \"" $2 "\",";		
		}
	}' | sed '$ s/,$//' > temp.json

	echo "{" > $outputJSONPath
	cat temp.json >> $outputJSONPath
	echo "}" >> $outputJSONPath

	rm temp.json
}

usage() {
	echo "Usage: $0 [-i <inputPath>] [-o <outputPath>] [-d] [-e <secondInput>] [-t <term>]"
	echo "Options:"
	echo " -i <inputPath>   Path to input Echo CSV file."
	echo " -o <outputPath>  Path to output file. (Default: ./subjToDept.json)"
	echo " -d               Only use this flag if you need to regenerate subjToDept.json"
	echo " -e <secondInput> Takes a second path to try and determine name/email mapping. Pass Echo CSV file to i argument."
	echo " -t <term>        The term for the converted file. (e.g. Fall 2021)"
	exit 1
}

main() { 
	local inputEchoCSVPath=""
	local outputCSVPath="./subjToDept.json"
	local regenerateSubjDeptJSON=false
	local secondInputCSVPath=""
	local term=""

	while getopts ":i:o:de:t:h" opt; do
	
		case ${opt} in
			i)
				inputEchoCSVPath="${OPTARG}"
				;;
			o)
				outputCSVPath="${OPTARG}"
				;;
			d)	
				regerateSubjDeptJSON=true
				;;
			e)
				secondInputCSVPath="${OPTARG}"
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
	
	if [[ "$regerateDeptMap" == true ]]; then
        	getDepartments "$inputEchoCSVPath" "$outputCSVPath"
  	elif [[ -n "$secondInputCSVPath" ]]; then
        	getEmails "$inputEchoCSVPath" "$secondInputCSVPath" "$outputCSVPath"
   	else
       		convertCSV "$inputEchoCSVPath" "$outputCSVPath" "$term"
    	fi
}

main "$@"
