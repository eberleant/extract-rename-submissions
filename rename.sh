# 1st param: number
# 2nd param: minimum number of digits
# addZeros(23, 4) gives you 0023
function add_zeros {
	num="$1"
	while [ "${#num}" -lt "$2" ]; do
		num="0$num"
	done
	echo "$num"
}

# 1st param: csv file
# 2nd param: path with all submission folders
# 3rd param: path to copy submission files to
# limitations:
	# csv file structure must have:
		# col1=firstname, col2=lastname
		# header row
	# can't have commas in the name, or any characters that don't work properly within a folder/filename
	# can't have newlines within foldername
	# can't have no first or last name
	# can't have more than one submission folder per student
	# can't have duplicate names
	# name capitalization matters
	# folder structure must be: OUTER_FOLDER > Firstname Lastname_* > SUBMISSION_FILES
	# for file renaming to work as intended:
		# no more than 9999 students
		# no more than 9 submission files per student
while IFS= read -r row; do
	while IFS=, read -r rownum firstname lastname leftover; do
		# rownum is an integer, firstname and lastname are not blank, leftover is blank
		if [[ !(-z "${rownum//[0-9]}" && -n "$rownum") || "$firstname" == "" || "$lastname" == "" || "$leftover" != "" ]]; then
			echo "Failed to parse row: $row"
			break
		fi
		rownum=$(add_zeros $rownum 4) # consistent number of digits: 1 becomes 0001, 135 becomes 0135, etc.
		folder=$(ls "$2" | grep "$firstname $lastname"_) # gets foldername containing student's submission files
		if [ $(echo "$folder" | wc -l) -eq 1 ] && [ "$folder" != "" ]; then
			filenum=1 # counting the number of submission files
			while IFS= read -r filename; do # get each submission file, copy to $3 and rename
				cp "$2/$folder/$filename" "$3/$rownum"_"$lastname"_"$firstname"_"$filenum.${filename##*.}"
				filenum=$((filenum + 1))
			done <<< "$(ls "$2/$folder")"
		else # no folder found (normally because there was no submission) or > 1 folders found
			echo "Failed to get submission for line $rownum: $firstname $lastname"
		fi
	done <<< "$row"
done <<< "$(csvcut -c 1,2 "$1" | csvcut -Hl | sed '1,2d')"