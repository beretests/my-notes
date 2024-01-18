```
# insert 'text ' to beginning of each line in file
sed 's/^/text /' filename

# delete last line in file
sed '$d' filename

# delete line and ovewrite file
sed -i 'nd' filename

# replace text
sed -i 's/old-text/new-text/g' input.txt
```