#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>

#include "dshlib.h"
 
Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd) {
    // Check for exit command
    if (strcmp(cmd->argv[0], EXIT_CMD) == 0) {
    printf("exiting...");
        exit(0);
    }

    // Check for cd command
    if (strcmp(cmd->argv[0], CD_CMD) == 0) {
        // Check for no argument and do nothing if so
        if (cmd->argc == 1) {
            return BI_EXECUTED;
        }
        
        // Attempt to change the directory
        if (chdir(cmd->argv[1]) != 0) {
            perror("cd");  // Print error message if chdir fails
        }
        return BI_EXECUTED;
    }

    return BI_NOT_BI;  // Command is not built-in
}
 
Built_In_Cmds match_command(const char *input) {
    if (strcmp(input, EXIT_CMD) == 0) {
        return BI_CMD_EXIT;
    }
    if (strcmp(input, CD_CMD) == 0) {
        return BI_CMD_CD;
    }
    if (strcmp(input, "rc") == 0) {
        return BI_RC;
    }
    return BI_NOT_BI;
}

int build_cmd_list(char *cmd_line, command_list_t *clist) {
    if (!cmd_line || !clist) {
        fprintf(stderr, "Error: Invalid input to build_cmd_list\n");
        return ERR_CMD_ARGS_BAD;
    }

    clist->num = 0; // Initialize command count

    char *token;
    char *saveptr;

    token = strtok_r(cmd_line, PIPE_STRING, &saveptr);  // Tokenize by pipe '|'
    while (token != NULL) {
        if (clist->num >= CMD_MAX) { // Check command limit
            return ERR_TOO_MANY_COMMANDS;  
        }

        cmd_buff_t *cmd = &clist->commands[clist->num];

        // Allocate memory for cmd_buffer to store the command segment
        cmd->_cmd_buffer = strdup(token);
        if (!cmd->_cmd_buffer) {
            perror("Error allocating memory for command buffer");
            return ERR_MEMORY;
        }

        //assigning input and output files in case of redirection
        cmd->argc = 0;
        cmd->input_file = NULL;
        cmd->output_file = NULL;

        char *arg_token;
        char *arg_saveptr;
        arg_token = strtok_r(cmd->_cmd_buffer, " ", &arg_saveptr);  // Tokenize arguments

        while (arg_token != NULL) {
            if (strcmp(arg_token, "<") == 0) {  // Input redirection
                arg_token = strtok_r(NULL, " ", &arg_saveptr);  // Get filename
                if (arg_token == NULL) {  // Check no filename after '<'
                    return ERR_CMD_ARGS_BAD;  
                }
                cmd->input_file = strdup(arg_token);  // Set input file
            }
            else if (strcmp(arg_token, ">") == 0) {  // Output redirection
                arg_token = strtok_r(NULL, " ", &arg_saveptr);  // Get filename
                if (arg_token == NULL) {  // Check no filename after '>'
                    return ERR_CMD_ARGS_BAD;
                }
                cmd->output_file = strdup(arg_token);  // Set output file
            }
            else {
                if (cmd->argc >= CMD_ARGV_MAX - 1) {
                    return ERR_CMD_OR_ARGS_TOO_BIG;  // Too many arguments
                }
                cmd->argv[cmd->argc] = arg_token;  // Add argument to argv
                cmd->argc++;
            }

            arg_token = strtok_r(NULL, " ", &arg_saveptr);  // Get next argument or operator
        }

        cmd->argv[cmd->argc] = NULL;  // Null terminate argv list

        if (cmd->argc == 0) {
            return WARN_NO_CMDS;
        }

        clist->num++;  // Increment command count
        token = strtok_r(NULL, PIPE_STRING, &saveptr);  // Next command (after pipe)
    }

    return OK;
}

int execute_pipeline(command_list_t *cmd_list) {
    int pipefd[2];  // Pipe file descriptors
    pid_t pid;
    int prev_fd = -1;  // Previous pipe's read end

    // Loop through each command in the command list
    for (int i = 0; i < cmd_list->num; i++) {
        if (i < cmd_list->num - 1) {
            // Create pipe for each command except the last one
            if (pipe(pipefd) == -1) {
                perror("pipe");
                return ERR_MEMORY;
            }
        }

        pid = fork();
        if (pid == -1) {
            perror("fork");
            return ERR_MEMORY;
        }

        if (pid == 0) {  // Child process
            // Handle input redirection if necessary
            if (cmd_list->commands[i].input_file != NULL) {
                FILE *input_file = fopen(cmd_list->commands[i].input_file, "r");
                if (input_file == NULL) {
                    perror("fopen input file");
                    exit(EXIT_FAILURE);
                }
                dup2(fileno(input_file), STDIN_FILENO);  // Redirect input
                fclose(input_file);
            } else if (prev_fd != -1) {
                // Redirect input from the previous pipe if its not the first command
                dup2(prev_fd, STDIN_FILENO);
                close(prev_fd);
            }

            // Handle output redirection if necessary
            if (cmd_list->commands[i].output_file != NULL) {
                FILE *output_file = fopen(cmd_list->commands[i].output_file, "w");
                if (output_file == NULL) {
                    perror("fopen output file");
                    exit(EXIT_FAILURE);
                }
                dup2(fileno(output_file), STDOUT_FILENO);  // Redirect output
                fclose(output_file);
            } else if (i < cmd_list->num - 1) {
                // Redirect output to pipe if not the last command
                close(pipefd[0]);  // Close read end of pipe
                dup2(pipefd[1], STDOUT_FILENO);  // Redirect output to pipe
                close(pipefd[1]);
            }

            // Execute the command
            if (execvp(cmd_list->commands[i].argv[0], cmd_list->commands[i].argv) == -1) {
                perror("execvp");
                exit(EXIT_FAILURE);
            }
        }

        // Parent process
        if (prev_fd != -1) {
            close(prev_fd);  // Close the previous read end of the pipe
        }

        // Close the write end of the pipe for all except the last command
        if (i < cmd_list->num - 1) {
            close(pipefd[1]);
        }

        // Save the read end of the pipe for the next command
        prev_fd = pipefd[0];
    }

    // Parent waits for all child processes
    for (int i = 0; i < cmd_list->num; i++) {
        waitpid(pid, NULL, 0);
    }

    return OK;
}

/*
 * Implement your exec_local_cmd_loop function by building a loop that prompts the
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 * use fgets to accept user input.
 *
 *      while(1){
 *        printf("%s", SH_PROMPT);
 *        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL){
 *           printf("\n");
 *           break;
 *        }
 *        //remove the trailing \n from cmd_buff
 *        cmd_buff[strcspn(cmd_buff,"\n")] = '\0';
 *
 *        //IMPLEMENT THE REST OF THE REQUIREMENTS
 *      }
 *
 *   Also, use the constants in the dshlib.h in this code.  
 *      SH_CMD_MAX              maximum buffer size for user input
 *      EXIT_CMD                constant that terminates the dsh program
 *      SH_PROMPT               the shell prompt
 *      OK                      the command was parsed properly
 *      WARN_NO_CMDS            the user command was empty
 *      ERR_TOO_MANY_COMMANDS   too many pipes used
 *      ERR_MEMORY              dynamic memory management failure
 *
 *   errors returned
 *      OK                     No error
 *      ERR_MEMORY             Dynamic memory management failure
 *      WARN_NO_CMDS           No commands parsed
 *      ERR_TOO_MANY_COMMANDS  too many pipes used
 *  
 *   console messages
 *      CMD_WARN_NO_CMD        print on WARN_NO_CMDS
 *      CMD_ERR_PIPE_LIMIT     print on ERR_TOO_MANY_COMMANDS
 *      CMD_ERR_EXECUTE        print on execution failure of external command
 *
 *  Standard Library Functions You Might Want To Consider Using (assignment 1+)
 *      malloc(), free(), strlen(), fgets(), strcspn(), printf()
 *
 *  Standard Library Functions You Might Want To Consider Using (assignment 2+)
 *      fork(), execvp(), exit(), chdir()
 */


int exec_local_cmd_loop() {
    char *cmd_buff = malloc(SH_CMD_MAX);
    command_list_t cmd_list;  // Parsed command list
    int result;


    while (1) {
        printf("%s", SH_PROMPT);
        if (fgets(cmd_buff, SH_CMD_MAX, stdin) == NULL) {
            printf("\n"); // Handle EOF (Ctrl+D)
            break;
        }

        // remove the trailing \n from cmd_buff
        cmd_buff[strcspn(cmd_buff, "\n")] = '\0';

        // If the input is empty, continue
        if (*cmd_buff == '\0') {
            printf("%s", CMD_WARN_NO_CMD);
            continue;
        }

        // Parse the command line into a command list
        result = build_cmd_list(cmd_buff, &cmd_list);

        if (result == WARN_NO_CMDS) {
            printf("%s", CMD_WARN_NO_CMD);
            continue;
        } else if (result == ERR_TOO_MANY_COMMANDS) {
            printf(CMD_ERR_PIPE_LIMIT, CMD_MAX);
            continue;
        }

        // If it's a single command, check if it's built-in
        if (cmd_list.num == 1) {
            cmd_buff_t *cmd = &cmd_list.commands[0];
            Built_In_Cmds cmd_type = match_command(cmd->argv[0]);
            if (cmd_type != BI_NOT_BI) {
                exec_built_in_cmd(cmd);
                continue;
            }
        }

        // Execute a pipeline if there are multiple commands
        result = execute_pipeline(&cmd_list);
        if (result != OK) {
            fprintf(stderr, "Error executing command: %d\n", result);
        }
    }

    return OK;
}
