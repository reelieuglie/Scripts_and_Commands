# Bash Scripts and Scripting


## Providing command arguments in Bash Scripts
```
foovar=""
barvar=""
while (( $# > 0 )) ; do
	case $1 in 
		-f|--foo) foovar="--region $2"; shift;;
		-b|--bar) barvar="--profile $2";shift ;;
		-h|--help) echo "Use -r for Region, and -p for profile";
			return 1;;
		\?) echo "Unknown Option";
	        		return 2;;
	        *) break;;
       esac
       shift
done
```
