1. How does the remote client determine when a command's output is fully received from the server, and what techniques can be used to handle partial reads or ensure complete message transmission?

The remote client determines when a command's full output is fully received from the server when it receives an EOF file character which is RDSH_EOF_CHAR in my code. To handle partial read and ensure complete message transmission, I continuously loop and read the input over and over until the EOF file is received. 

2. This week's lecture on TCP explains that it is a reliable stream protocol rather than a message-oriented one. Since TCP does not preserve message boundaries, how should a networked shell protocol define and detect the beginning and end of a command sent over a TCP connection? What challenges arise if this is not handled correctly?

A networked shell protocol should define and detect the beginning and end of a command sent over a TCP connection by having a delimeter of some kind being used to seperate each command. If this is not handled correctly the server or client could be stuck infinetly looping trying to look for an end of file character that does not exist which would cause freezing and crashing. 

3. Describe the general differences between stateful and stateless protocols.

Stateful protocls maintain a state between the client server meaning the server remembers a client's previous actions, which can allow greater interactability at the cost of server costs as well as being harder to scale than stateless protocols. Stateless protocls do not maintain a state between the client server meaning the server does not remember a client's previous actions, meaning the requests have to be simpler and can not be linked, which is less server intensive and easier to scale. 

4. Our lecture this week stated that UDP is "unreliable". If that is the case, why would we ever use it?

UDP is still used when speed is more important than reliability. A great example of this is live video streaming, where speed is very important while having a little bit of lost data is not a big deal. 

5. What interface/abstraction is provided by the operating system to enable applications to use network communications?

There are many interface/abstractions that are provided by the operating system in order to enable appications to use network communications are methods with in the Socket API,  such as socket(), send(), and recv().