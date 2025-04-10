# Bash Scripts and Scripting


## Providing command arguments in Bash Scripts
```
####
# Functions
####

usage() {
    cat <<EOF
Usage: $0 [options]

Options:
    -h|--help  Usage info; functionally this message
    -f|--foo   Foo; some info about foo
    -b|--bar   Bar; some info about bar
 For more info, see the following links:
 * Some other info
 EOF

}

unknown_option_help() {
	cat <<EOF
+++ Unknown Option(s) "$@" Provided +++
+++ See Help Below +++
	usage
EOF
}

####
# Collect input for variables
####

while (( $# > 0 )); do
	case $1 in 
		-f|--foo) foo=$2; shift;;
		-b|--bar) bar=$2; shift;;
		-h|--help) usage; 
			exit 1;;
		*) unknown_option_help "$@"; exit 2;;
	esac
	shift
done

```

## Login Shells and Dotfiles
```
FILES
       /bin/bash
              The bash executable
       /etc/profile
              The systemwide initialization file, executed for login shells
       /etc/bash.bash_logout
              The systemwide login shell cleanup file, executed when a login shell exits
       ~/.bash_profile
              The personal initialization file, executed for login shells
       ~/.bashrc
              The individual per-interactive-shell startup file
       ~/.bash_logout
              The individual login shell cleanup file, executed when a login shell exits
       ~/.inputrc
              Individual readline initialization file
```
