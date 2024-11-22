### Remove Blank Lines from a file
```
sed '/^$/d' $insertFilePathHere
```
### Find the field numbers for a CSV file (replace $csv_filename with the name and path of the .csv file)
```
cat $csv_filename| head -n 1 | tr ',' "\n" | cat -n
```
### Turn Epoch Timestamps into Human Readable
* This assumes a CSV,column `$5` is where the timestamp is, and it's got milliseconds (that's what substr is for). It will print simply column `$5`; adjust columns as needed. 
```
 awk -F, '{print $5=strftime("%c",substr($5,1,10))}
```

### grep for just `var`; like when searching for variables in a terraform template
```
grep -oE '\bvar.*\b'
```
