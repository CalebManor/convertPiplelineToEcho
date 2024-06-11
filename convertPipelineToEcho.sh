#!/usr/bin/env bash

main() { 
	inputPath=""
	outputPath="./subjToDept.json"
	getDepts=false
	secondInput=""
	term=""

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
