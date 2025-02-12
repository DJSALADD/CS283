#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "dshlib.h"

/*
 *  build_cmd_list
 *    cmd_line:     the command line from the user
 *    clist *:      pointer to clist structure to be populated
 *
 *  This function builds the command_list_t structure passed by the caller
 *  It does this by first splitting the cmd_line into commands by spltting
 *  the string based on any pipe characters '|'.  It then traverses each
 *  command.  For each command (a substring of cmd_line), it then parses
 *  that command by taking the first token as the executable name, and
 *  then the remaining tokens as the arguments.
 *
 *  NOTE your implementation should be able to handle properly removing
 *  leading and trailing spaces!
 *
 *  errors returned:
 *
 *    OK:                      No Error
 *    ERR_TOO_MANY_COMMANDS:   There is a limit of CMD_MAX (see dshlib.h)
 *                             commands.
 *    ERR_CMD_OR_ARGS_TOO_BIG: One of the commands provided by the user
 *                             was larger than allowed, either the
 *                             executable name, or the arg string.
 *
 *  Standard Library Functions You Might Want To Consider Using
 *      memset(), strcmp(), strcpy(), strtok(), strlen(), strchr()
 */


 
int build_cmd_list(char *cmd_line, command_list_t *clist) {
    clist->num = 0; // Initialize command number

    // Initialize a pointer to scan through the command line
    char *cmd = cmd_line;

    // Loop through each command split by pipes '|'
    while (cmd != NULL && *cmd != '\0') {
        // Trim leading spaces from the command
        while (*cmd == ' ') cmd++;

        // Find the next pipe '|' or end of string for the last command
        char *pipe_pos = strchr(cmd, PIPE_CHAR);
        if (pipe_pos != NULL) {
            // Temporarily null-terminate the command at the pipe position
            *pipe_pos = '\0';
        }

        // Trim trailing spaces from the command
        char *end = cmd + strlen(cmd) - 1;
        while (end > cmd && *end == ' ') end--;  // Move to the last non-space character
        *(end + 1) = '\0';  // Null-terminate the trimmed string

        // If we've exceeded the maximum allowed commands, return error
        if (clist->num >= CMD_MAX) {
            return ERR_TOO_MANY_COMMANDS;
        }

        // Splitting the command and arguments at the first space
        char *exe = cmd;  // Start of the command
        char *arg_start = strchr(cmd, ' ');  // Find the first space

        if (arg_start != NULL) {
            // Null terminate the command part
            *arg_start = '\0';
            arg_start++;  // Move past the space to the start of arguments
        }

        // Store the command
        strcpy(clist->commands[clist->num].exe, exe);

        // If there are arguments, process them
        if (arg_start != NULL) {
            char *arg = arg_start;
            clist->commands[clist->num].args[0] = '\0';  // Initialize args as an empty string

            // Split the arguments
            while (*arg != '\0') {
                // Skip leading spaces in the argument string
                while (*arg == ' ') arg++;

                if (*arg == '\0') break;  // If the argument string ends, break

                // Find the end of the current argument which is the first space or end of string
                char *arg_end = strchr(arg, ' ');
                if (arg_end == NULL) {
                    // If no more spaces, the argument goes to the end of the string
                    strcat(clist->commands[clist->num].args, arg);
                    break;
                } else {
                    // Temporarily null-terminate the argument to append it
                    *arg_end = '\0';
                    strcat(clist->commands[clist->num].args, arg);
                    strcat(clist->commands[clist->num].args, " ");  // Add space after the argument
                    // Move the pointer to next argument
                    arg = arg_end + 1;
                }
            }
        } else {
            //  If no arguments, set args to empty string
            clist->commands[clist->num].args[0] = '\0';
        }

        clist->num++;

        // If there are more commands, move to the next one
        if (pipe_pos != NULL) {
            cmd = pipe_pos + 1; // Skip over the pipe character
        } else {
            break; // Exit the loop if there are no more commands
        }
    }

    // Return a error if no commands were provided
    if (clist->num == 0) {
        return WARN_NO_CMDS;
    }

    return OK;
}