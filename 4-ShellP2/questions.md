1. Can you think of why we use `fork/execvp` instead of just calling `execvp` directly? What value do you think the `fork` provides?

    > **Answer**: If we directly called 'execvp' we would instantly end our shell process which we do not want. The 'fork'provides value in the form of allowing us to execute a child task without ending the main shell, while also providing help in implementing piping in the future. 

2. What happens if the fork() system call fails? How does your implementation handle this scenario?

    > **Answer**:  If the fork system call fails, the child process is not created and a fail return code is sent. My implemenation handles this scenario by not calling execvp if the fork fails and properly printing an error message.

3. How does execvp() find the command to execute? What system environment variable plays a role in this process?

    > **Answer**: When calling execvp(), it searches for the command listed in the PATH environment variable. If the command contains a /, it is treated as a direct path, otherwise, execvp() checks each directory in PATH until it finds an executable file. If no match is found, it returns an error in the form of -1.

4. What is the purpose of calling wait() in the parent process after forking? What would happen if we didn’t call it?

    > **Answer**:  The purpose of calling wait() in the parent process after forking is to ensure that zombie processes arent created and to ensure that there is synchronization between the parent and child processes. If we didn't call wait(), zombie children would be created in which the children continue to run, which consumes resources, and the parent would be repeatedly trying to execute without properly waiting for the child process to complete.

5. In the referenced demo code we used WEXITSTATUS(). What information does this provide, and why is it important?

    > **Answer**:  WEXITSTATUS() provides the exist status of a child process after it has terminated. This exit status is important because it allows you to properly detect and avoid future errors.

6. Describe how your implementation of build_cmd_buff() handles quoted arguments. Why is this necessary?

    > **Answer**: My implementation handled quoted arguments by parsing the first quote and then taking the entire string up to the last quote and the replacing that last quote with a '\0'. This is necessary as it allows for the spaces in the quoted text to be treated as the same argument. 

7. What changes did you make to your parsing logic compared to the previous assignment? Were there any unexpected challenges in refactoring your old code?

    > **Answer**: I had to change the way I handled arguments to allow for quoted strings to be passed as arguments and removing all of the piping parsing code. I did not run into any unexpected challenges in refactoring my old code.

8. For this quesiton, you need to do some research on Linux signals. You can use [this google search](https://www.google.com/search?q=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&oq=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBBzc2MGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8) to get started.

- What is the purpose of signals in a Linux system, and how do they differ from other forms of interprocess communication (IPC)?

    > **Answer**:  The purpose of signals in a linux system is to notify processes of events like termination or errors. Unlike other IPCs, signals do not require an explicit communication channel between process since they are sintead sent by the kernel. 

- Find and describe three commonly used signals (e.g., SIGKILL, SIGTERM, SIGINT). What are their typical use cases?

    > **Answer**: SIGKILL immediately terminates a process and cannot be caught, ignored or handled. It is used when a process must be forcefully stopped or is unresponsive. SIGTERM requests a program to terminate, allowing for the program to clean up before doing so. It is used when wanting to give the program's data a chance to save and to release resources. SIGINT interrupts a process but does not terminate it. It is used when wanting to stop interactive scripts without forcing termination.

- What happens when a process receives SIGSTOP? Can it be caught or ignored like SIGINT? Why or why not?

    > **Answer**:  When a process receives SIGSTOP, it immediately becomes suspended and stops executing until it is given SIGCONT. SIGSTOP can not be stopped or ignored because it it is designed to be a control mechanism by which the kernel is able to reliablely suspend processes that can always be unpaused.
