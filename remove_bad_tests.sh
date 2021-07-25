#!/usr/bin/sh

# Set the variable for bash behavior
#shopt -s nullglob
#shopt -s dotglob

# 1. Generate a new scan file
# 2. Searching all runs and find pdf or afp directory
# 3. If pdf or afp directory exist leave that run, else remove it
# 4. Remove the new scan file

# 1. Generate a new scan file
# for dir in `ls -d */`
# do
	# echo $dir >> new_scan_datei
# done

# 2. Searching all runs and find pdf or afp directory
# $SCENARIOS=/ccb/ccb20b/sharereg/TL/szenarios_batch/
# pack452/CU-000037803/test_results/20210526_091354/condition_at_run/DOCUMENTS/io_files/AFP
# pack452/*/test_results/*/condition_at_run/DOCUMENTS/io_files/AFP
#for i in `cat scan_rm_datei`
for dir in `cat new_scan_datei`
do
	echo $dir
	echo $(ls -d $dir/* > scan_datei)
	for k in `cat scan_datei` ; do
		echo $(ls -d $k/* > scan_afp)
	done
done
for i in `cat scan_afp`
do
	for j in `ls -A $SCENARIOS/$i/*/condition_at_run/DOCUMENTS/io_files/AFP`
	do

# 3. If pdf or afp directory exist leave that run, else remove it
		if [ "$(ls -A $SCENARIOS/$i/condition_at_run/DOCUMENTS/io_files/AFP)" ]; then
			echo "$SCENARIOS/$i/condition_at_run/DOCUMENTS/io_files/AFP ist nicht leer"
		else
			echo "$SCENARIOS/$i/condition_at_run/DOCUMENTS/io_files/AFP ist leer"
		fi
	done

# 4. Remove the new scan file
done

# # Die if dir name provided on command line
# [[ $# -eq 0 ]] && { echo "Usage: $0 dir-name"; exit 1; }
 
# # Check for empty files using arrays 
# chk_files=(${1}/*)
# (( ${#chk_files[*]} )) && echo "Files found in $1 directory." || echo "Directory $1 is empty."
# /ccb/ccb20b/sharereg/TL/szenarios_batch/Gemini_Kunden//CU-000036477/test_results/*/condition_at_run

# ls -d Gemini_Kunden/* > scan_datei
# Gemini_Kunden/CU-000036477
# ls -d $k/* > scan_afp
# ls -d Gemini_Kunden/CU-000036477/* > scan_afp
# Gemini_Kunden/CU-000036477/test_control
# Gemini_Kunden/CU-000036477/test_results
# ls -A /ccb/ccb20b/sharereg/TL/szenarios_batch/Gemini_Kunden/CU-000036477/test_results/*/condition_at_run/DOCUMENTS/io_files/AFP

# [ -f <file> ]	True if file exists and if it is a regular file
# [ -d <file> ]	True if file exists and if it is a directory
# [ -s <file> ]	True if file exists and its size is greater than zero
# [ -L <file> ]	True if file exists and if it is a symbolic link
# [ -p <file> ]	True if file is a name pipe (FIFO)
# [ -b <file> ]	True if file is a block special device
