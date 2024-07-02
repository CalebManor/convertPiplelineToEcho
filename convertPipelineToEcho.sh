#!/usr/bin/env bash

convertCSV() {
	local inputCSV="$1"
	local outputEcho="$2"
	local term="$3"	
	
	declare -A subjToDept
	declare -A nameToEmail

	while IFS="=" read -r key value; do
		subjToDept[$key]=$value
	done < <(jq -r 'to_entries[] |"\(.key)=\(.value)"' subjToDept.json)

	while IFS="=" read -r key value; do
		nameToEmail[$key]=$value
	done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' nameToEmail.json)

	local org="HU - Main Campus"

	echo "Organization, Department, Course Code, Course Name, Section Code, Primary Instructor Email, Secondary Instructor Emails" > "$outputEcho"

	IFS=','
	while read -r DEPT SUBJ TITLE INSTR; do
		if [[ "$DEPT" == "Dept" ]]; then
			continue 
		fi
	
		local organization="$org"
		local dept="${subjToDept[$SUBJ]:-}"
		local courseCode="$SUBJ"
		local className="$TITLE"
		local email="${nameToEmail[$INST]:-TBA}"

		echo "$orgName, $dept, $courseCode, $className, $term,, $email" >> "$outputEcho" 
	done < "$inputCSV"	
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
	
