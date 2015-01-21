#!/bin/bash

#
# Printing and error reporting utility functions.
#  See the end of this file for usage examples.
#
# You can find more bash utility / helper scripts at [https://github.com/bitrise-io/steps-utils-bash-toolkit](https://github.com/bitrise-io/steps-utils-bash-toolkit)
#

#
# Prints the given command, then executes it
#  Example: print_and_do_command echo 'hi'
#
function print_and_do_command {
	echo # empty line
	echo "-> $ $@"
	"$@"
}


#
# This one expects a string as it's input, and will eval it
# 
# Useful for piped commands like this: print_and_do_command_string "printf '%s' \"$filecont\" > \"$testfile_path\""
#  where calling print_and_do_command function would write the command itself into the file as well because
#  of the precedence order of the '>' operator
#
function print_and_do_command_string {
	echo "-> $ $1"
	eval "$1"
}

#
# Sets a "cleanup" function which will be called
#  from the print_and_do_command_exit_on_error() and fail_if_cmd_error()
#  methods right before exit.
function set_error_cleanup_function {
	CLEANUP_ON_ERROR_FN=$1
}

#
# Combination of print_and_do_command and error checking, exits if the command fails
#  Example: print_and_do_command_exit_on_error rm some/file/path
function print_and_do_command_exit_on_error {
	print_and_do_command "$@"
	cmd_exit_code=$?
	if [ ${cmd_exit_code} -ne 0 ]; then
		echo " [!] Failed!"
		if [ "$(type -t ${CLEANUP_ON_ERROR_FN})" == "function" ] ; then
			echo " (i) Calling cleanup function before exit"
			CLEANUP_ON_ERROR_FN
		else
			echo " (i) No cleanup function defined - exiting now"
		fi
		exit ${cmd_exit_code}
	fi
}

#
# Check the LAST COMMAND's result code and if it's not zero
#  then print the given error message and exit with the command's exit code
#
function fail_if_cmd_error {
	last_cmd_result=$?
	err_msg=$1
	if [ ${last_cmd_result} -ne 0 ]; then
		echo "${err_msg}"
		if [ "$(type -t ${CLEANUP_ON_ERROR_FN})" == "function" ] ; then
			echo " (i) Calling cleanup function before exit"
			CLEANUP_ON_ERROR_FN
		else
			echo " (i) No cleanup function defined - exiting now"
		fi
		exit ${last_cmd_result}
	fi
}

# EXAMPLES:

# example with 'print_and_do_command_exit_on_error':
#   print_and_do_command_exit_on_error brew install git
 
# OR with the combination of 'print and do' and 'fail':
# print_and_do_command brew install git
#   fail_if_cmd_error "Failed to install git!"
