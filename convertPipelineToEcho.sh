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

getDepartments(){
	local formattedPath=$1
	local outputPath=$2
	local tempFile="temp.json"

	# Read CSV and generate JSON mapping

	awk -F ',' 'NR > 1 {
		split($1, a, "-");
		if (!seen[a[1]]++) {
			print "\"" a[1] "\": \"" $2 "\",";		
		}
	}' "$formattedPath" | sed '$ s/,$//' > "$tempFile"

	echo "{" > $outputPath
	cat $tempFile  >> $outputPath
	echo "}" >> $outputPath

	rm "$tempFile"
}

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

	# Write output to JSON file

	{
		echo "{"
		for instructorName in "${!nameToEmailMap[@]}"; do
			echo "\"$instructorName\": \"${nameToEmailMap[$instructorName]}\","	
		done | sed '$ s/,$//'
		echo "}" 
	} > "$outputJSONPath"
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
