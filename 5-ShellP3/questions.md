1. Your shell forks multiple child processes when executing piped commands. How does your implementation ensure that all child processes complete before the shell continues accepting user input? What would happen if you forgot to call waitpid() on all child processes?

My implementation ensure that all child process complete before the shell continues accepting user input by having each parent process call waitpid(pid, NULL, 0) for all of its children. If I forgot to call waitpid() on all child processes, zombie processes could be created, causing dips in performance with the zombie process which would continuously run, and this would take system resources, which could harm preformance.

2. The dup2() function is used to redirect input and output file descriptors. Explain why it is necessary to close unused pipe ends after calling dup2(). What could go wrong if you leave pipes open?

It is necessary to close unused pipe ends after calling dup2() because a process on the receiving end of a pipe needs to know when its input is finished, and this can not happen if the pipe is left open. If the pipes are left open, the zombie processes could be created eating system resources, and data could be unexepected transferred through the pipe. 

3. Your shell recognizes built-in commands (cd, exit, dragon). Unlike external commands, built-in commands do not require execvp(). Why is cd implemented as a built-in rather than an external command? What challenges would arise if cd were implemented as an external process?

The cd command is implemented as a built in rather than external command because it allows for the shell to directly call the chdir command which is more efficient. If cd were implemented as an external process, it would have to be forked and exectued, which would be very inefficent for a simple command.

4. Currently, your shell supports a fixed number of piped commands (CMD_MAX). How would you modify your implementation to allow an arbitrary number of piped commands while still handling memory allocation efficiently? What trade-offs would you need to consider?

I would keep my current implementation by using malloc on my command input memory as opposed to a fixed array. This setup makes it so the memory access is slower, but the memory is able to be dynamically created and managed. 