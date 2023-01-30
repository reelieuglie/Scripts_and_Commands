### Remove Blank Lines from something
```
sed '/^$/d'
```
### Find the field numbers for a CSV file (replace $csv_filename with the name and path of the .csv file)
```
cat $csv_filename| head -n 1 | tr ',' "\n" | cat -n
```
