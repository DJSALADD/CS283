#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "dshlib.h"

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

extern void print_dragon();

int build_cmd_buff(char *cmd_buff, cmd_buff_t *cmd) {
    if (!cmd_buff || !*cmd_buff) {
        return WARN_NO_CMDS;
    }

    char *buffer = malloc(strlen(cmd_buff) + 1);
    if (!buffer) {
        return ERR_MEMORY;
    }
    strcpy(buffer, cmd_buff);

    cmd->argc = 0;
    cmd->_cmd_buffer = buffer;

    char *token = buffer;
    int in_quotes = 0;

    while (*token) {
        // Skip leading spaces
        while (*token == ' ' && !in_quotes) {
            token++;
        }

        if (*token == '\0') {
            break;
        }

        // Check if token starts with quote
        if (*token == '"') {
            in_quotes = 1;
            token++;  // Skip opening quote
        }

        cmd->argv[cmd->argc++] = token;

        // Move to the next space or end of quoted string
        while (*token && (in_quotes || *token != ' ')) {
            if (*token == '"' && in_quotes) {
                *token = '\0';  // End quote terminate string
                in_quotes = 0;
            }
            token++;
        }

        if (*token) {  // End argument
            *token = '\0';
            token++;
        }

        if (cmd->argc >= CMD_ARGV_MAX - 1) {
            free(buffer);
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }
    }

    cmd->argv[cmd->argc] = NULL;  // Null-terminate the argument list
    return OK;
}

Built_In_Cmds exec_built_in_cmd(cmd_buff_t *cmd) {
    // Check for exit command
    if (strcmp(cmd->argv[0], EXIT_CMD) == 0) {
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

    // Check for dragon command
    if (strcmp(cmd->argv[0], DRAGON_CMD) == 0) {
        print_dragon();
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
    if (strcmp(input, DRAGON_CMD) == 0) {
        return BI_CMD_DRAGON;
    }
    return BI_NOT_BI;
}

int exec_local_cmd_loop()
{
    char *cmd_buff = malloc(SH_CMD_MAX);;
    int rc = 0;
    cmd_buff_t cmd;

    while (1) {
        printf("%s", SH_PROMPT);

        if (fgets(cmd_buff, SH_CMD_MAX, stdin) == NULL) {
            printf("\n");
            break;
        }

        // remove the trailing \n from cmd_buff
        cmd_buff[strcspn(cmd_buff, "\n")] = '\0';


        // TODO IMPLEMENT parsing input to cmd_buff_t *cmd_buff
        rc = build_cmd_buff(cmd_buff, &cmd);
        if (rc == WARN_NO_CMDS) {
            printf(CMD_WARN_NO_CMD);
            continue;
        } else if (rc != OK) {
            printf("Error: Failed to parse command\n");
            continue;
        }

        // if built-in command, execute builtin logic for exit, cd (extra credit: dragon)
        // the cd command should chdir to the provided directory; if no directory is provided, do nothing
        Built_In_Cmds cmd_type = match_command(cmd.argv[0]);
        if (cmd_type != BI_NOT_BI) {
            exec_built_in_cmd(&cmd);
            continue;
        }

        // TODO IMPLEMENT if not built-in command, fork/exec as an external command
        // for example, if the user input is "ls -l", you would fork/exec the command "ls" with the arg "-l"
        pid_t pid = fork();

        if (pid == 0) {  // Child process
            execvp(cmd.argv[0], cmd.argv);
            perror("execvp");  // If execvp fails
            exit(ERR_EXEC_CMD);
        } 
        else if (pid > 0) {  // Parent process
            int status;
            waitpid(pid, &status, 0);  // Wait for child process
        } 
        else {  // Fork failed
            perror("fork");
        }
    }
    
    free(cmd_buff);
    return OK;
}
