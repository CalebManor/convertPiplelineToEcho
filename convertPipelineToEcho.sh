#!/usr/bin/env bash

getEmails() {
	local formattedCSVPath=$1
	local unformattedCSVPath=$2
	local outputJSONPath=$3

	declare -A nameToEmailMap
	
	# Get instructor names from CSV
	tail -n +2 "$unformattedCSVPath" | awk -F',' '{print $2}' | while IFS= read -r instructorName; do

		# Normalize instructor name to lowercase without spaces for association
		lowerInstructorName="${instructorName,,}" 
		lowerInstructorName="${lowerName// /}"

		emailKey="lowerInstructorName"

		#Extract instructor emails by matching the emailKey 

		associatedEmail=$(tail -n +2 "formattedCSVPath" |
		 awk -v emailKey="$emailKey" -F',' '$2 ~ emailKey {print $1; exit}')

		# Populate map with Instructor/Email mapping
		nameToEmailMap["$instructorName"]="${associatedEmail:-none}"
	done
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
	
