#!/usr/bin/env bash

main() { 
	inputPath=""
	outputPath="./subjToDept.json"
	getDepts=false
	secondInput=""
	term=""

	while getops ":i:o:de:t:h" opt; do
		case ${opt} in
			i)
				inputPath="${OPTARG}"
				;;
			o)
				outputPath="${OPTARG}"
				;;
			d)
				getDept=true
				;;
			e)
				secondInput="${OPTARG}"
				;;
			t)
				term="${OPTARG}"
				;;
			h)
				
				;;
			\?)
				echo "Invalid option: $OPTARG"
				
				;;
			:)
				echo "Option -$OPTARG requires an argument."
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

if ["$0" = "$BASH_SOURCE"]; then
	main "$@"
fi
