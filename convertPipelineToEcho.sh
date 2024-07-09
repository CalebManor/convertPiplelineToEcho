#!/usr/bin/env bash

convertCSV() {
	local inputCSV="$1"
	local outputEcho="$2"
	local term="$3"	
	
	declare -A subjToDept
	declare -A nameToEmail
	
	# Load JSON mappings into corresponding associative arrays
	# Uses jq for easier JSON processing
	# https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/018-working-with-json-in-bash-using-jq.md

	while IFS="=" read -r subject department; do
		subjToDept[$subject]=$department
	done < <(jq -r 'to_entries[] |"\(.key)=\(.value)"' subjToDept.json)

	while IFS="=" read -r instructorName email; do
		nameToEmail[$instructorName]=$email
	done < <(jq -r 'to_entries[] | "\(.key)=\(.value)"' nameToEmail.json)

	local org="HU - Main Campus"
	
	# Write header row to output Echo file
	echo "Organization, Department, Course Code, Course Name, Term,  Section Code, Primary Instructor Email, Secondary Instructor Emails" > "$outputEcho"

	# Reads and processes each row from inputCSV and writes the converted data to outputEcho
	IFS=','
	while read -r CAMPUS SUBJ SECT TITLE INSTR; do
		if [[ "$CAMPUS" == "CAMPUS" ]]; then
			continue 
		fi
	
		local organization="$org"
		local dept="${subjToDept[$SUBJ]:-}"
		local sectionCode="${SECT##*.}"
		local courseCode="$SUBJ"
		local className="$TITLE"
		local email="${nameToEmail[$INST]:-TBA}"

		echo "$organization, $dept, $courseCode, $className, $term, $sectionCode, $email"
			 >> "$outputEcho" 
	done < "$inputCSV"	
}

usage() {
	echo "Usage: $0 [-i <inputPath>] [-o <outputPath>] [-d] [-e <secondInput>] [-t <term>]"
	echo "Options:"
	echo " -i <inputPath>   Path to input Echo CSV file."
	echo " -o <outputPath>  Path to output file. (Default: ./subjToDept.json)"
	echo " -d               Only use this flag if you need to regenerate subjToDept.json"
	echo " -e <secondInput> Takes a second path to try and determine name/email mapping. Pass Echo CSV file to i argument."
	echo " -t <term>        The term for the converted file. (e.g. Fall 2021)" exit 1 }

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
	
