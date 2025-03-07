
# Distribute bashrc into smaller, more specific files
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#echo  $SCRIPT_DIR

. $SCRIPT_DIR/.shells/defaults
. $SCRIPT_DIR/.shells/functions
. $SCRIPT_DIR/.shells/exports
. $SCRIPT_DIR/.shells/alias
#. $SCRIPT_DIR/.shells/prompt   # Fancy prompt with time and current working dir
. $SCRIPT_DIR/.shells/git      # Conveniences - Display current branch etc

uptime   # Needs: 'sudo apt-get install lsscsi'
free -h
