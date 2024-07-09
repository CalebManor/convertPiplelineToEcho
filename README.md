# Pipeline To Echo CSV Converter
This tool is a Bash conversion of a Python script written to convert Harding Pipeline CSV files to Echo compliant CSV files.

The tool expects a JSON file mapping subjects to departments and another JSON file mapping instructor names to emails. These must be at ./subjToDept.json and ./nameToEmail.json respectively - both in reference to convertPipelineToEcho.py.

## Dependencies
This tool has 1 dependency for the sake of brevity and readability and because it is intended only for a handful of users.   
https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/018-working-with-json-in-bash-using-jq.md

### Usage
convertPipelineToEcho.sh [-i <inputPath>] [-o <outputPath>] [-d] [-e <secondInput>] [-t <term>]  
Options:  
-i <inputPath>		Path to input Echo CSV file."  
-o <outputPath>		Path to output file. (Default: ./subjToDept.json)"  
-d			Only use this flag if you need to regenerate subjToDept.json"  
-e <secondInput>	Takes a second path to try and determine name/email mapping. Pass Echo CSV file to i argument."  
-t <term>		The term for the converted file. (e.g. Fall 2021)"  
	
