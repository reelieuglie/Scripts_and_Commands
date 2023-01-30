### Search through filesystem, two directories deep, starting at root (`/`) and respond with the largest directories
```
sudo du -mah --max-depth=2 / 2>/dev/null | sort -rh | less
```
