# ==============================================================================
# Remote build server details
# ==============================================================================
hostname="todddavies.co.uk"
hostport=22
remoteuser="root"

# ==============================================================================
# Author details
# ==============================================================================
authorName="Todd Davies"

# ==============================================================================
# Compilation settings
# ==============================================================================
# What directories to compile .tex files in. Seperate by spaces e.g:
# directories=(diagrams automata)
directories=();

# Use parallel compilation (true/false)
parallelCompile=1
preCompileCommands=preCommands.tmp
commands=commands.tmp
logFile=parallelCompile.log
