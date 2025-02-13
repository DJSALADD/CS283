1. In this assignment I suggested you use `fgets()` to get user input in the main while loop. Why is `fgets()` a good choice for this application?

    > **Answer**:  fgets() is a good schoice for this application because it allows for an easy readable line that can be stopped at a max length. 

2. You needed to use `malloc()` to allocte memory for `cmd_buff` in `dsh_cli.c`. Can you explain why you needed to do that, instead of allocating a fixed-size array?

    > **Answer**:  Using malloc() allows for the user input to be safely accepted and past into the variable without having to reserve an absurd amount of space. Malloc also allows for dynamic memory allocation that can be changed at runtime. Lastly, malloc ensure that the buffer has enough space since the buffer will be allocated on the heap which has more space than the stack.


3. In `dshlib.c`, the function `build_cmd_list(`)` must trim leading and trailing spaces from each command before storing it. Why is this necessary? If we didn't trim spaces, what kind of issues might arise when executing commands in our shell?

    > **Answer**:  We need to trim the spaces because the determination between the commands being split at the "|"s means that we need to be able to quickly iterate from one command to the next and trimming spaces accomplishes this.

4. For this question you need to do some research on STDIN, STDOUT, and STDERR in Linux. We've learned this week that shells are "robust brokers of input and output". Google _"linux shell stdin stdout stderr explained"_ to get started.

- One topic you should have found information on is "redirection". Please provide at least 3 redirection examples that we should implement in our custom shell, and explain what challenges we might have implementing them.

    > **Answer**:  We should implement adding . We would have trouble with all of these as we would have to introduce a completely new parsing system for each of the three different piping notations.

- You should have also learned about "pipes". Redirection and piping both involve controlling input and output in the shell, but they serve different purposes. Explain the key differences between redirection and piping.

    > **Answer**:  Redirection directs input or output to or from files while piping connects output of one command to another commands input. Redirection only uses two files, while piping can use multiple commands. Piping uses the "|" character while redirection uses ">", "<", and "<<".

- STDERR is often used for error messages, while STDOUT is for regular output. Why is it important to keep these separate in a shell?

    > **Answer**:  Keeping STDERR and STDOUT seperate allows for greater control and helps avoid errors. By keeping them seperate, you add the ability to filter if STDERR output is allowed to be piped 
    and allow for distinguishing for piping in between the two which is useful for functionality and debugging.

- How should our custom shell handle errors from commands that fail? Consider cases where a command outputs both STDOUT and STDERR. Should we provide a way to merge them, and if so, how?

    > **Answer**:  When a command fails, our custom shell should properly display to the user that it occurs and allow for filtering. When a command outputs STDERR we should be able to distinguish it and allow for it to be sent to a different file through redirection. When a command fails but provides STDOUT, we should be able to feed it through piping and redirection. We could merge them through a hybrid comand such as ">&" that would combine the output and direct it into another file. 
