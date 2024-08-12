
# Distribute bashrc into smaller, more specific files

. .shells/defaults
. .shells/functions
. .shells/exports
. .shells/alias
#. .shells/prompt   # Fancy prompt with time and current working dir
. .shells/git      # Conveniences - Display current branch etc

uptime   # Needs: 'sudo apt-get install lsscsi'
free -h
