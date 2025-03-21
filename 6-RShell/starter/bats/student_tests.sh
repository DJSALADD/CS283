#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

# LOCAL TESTS

@test "Local: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Local: Echo test with no arguments" {
    run "./dsh" <<EOF
echo
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="localmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Local: Echo with arguments" {
    run "./dsh" <<EOF
echo Hello World
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="HelloWorldlocalmodedsh4>dsh4>cmdloopreturned0"

     echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    # Check if the correct output is printed
    [ "$status" -eq 0 ]
    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: Empty input" {
    run "./dsh" <<EOF
<EOF>
EOF

    # Ensure no output and status is 0 (exit gracefully)
    [ "$status" -eq 0 ]
}

@test "Local: Invalid command syntax" {
    run "./dsh" <<EOF
ls | | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="localmodedsh4>warning:nocommandsprovideddsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: Multiple command pipe" {
    run "./dsh" <<EOF
ls | grep dshlib.c | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="1localmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Local: Built-in exit command" {
    run "./dsh" <<EOF
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for eas
    expected_output="localmodedsh4>exiting..."

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Local: Invalid second command" {
    run "./dsh" <<EOF
ls | awesomecommand
EOF
    
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvp:Permissiondeniedlocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Local: Prompt format" {
    run "./dsh" <<EOF
echo Test
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="Testlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Local: Multiple commands (without pipe)" {
    run "./dsh" <<EOF
echo Hello
echo World
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="HelloWorldlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Local: Invalid command execution" {
    run "./dsh" <<EOF
nonexistentcommand
EOF
    
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvp:Permissiondeniedlocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Local: Exceeding pipe limit" {
    run "./dsh" <<EOF
echo test | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Replace %d with the actual limit your shell enforces
    expected_output="localmodedsh4>error:pipinglimitedto8commandsdsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match (modify if necessary)
    [ "$stripped_output" = "$expected_output" ]

    # Check if exit status is nonzero (indicating an error)
    [ "$status" -eq 0 ]
}

@test "Local: Sleep command" {
    run "./dsh" <<EOF
sleep 3
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="localmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$status" -eq 0 ]
    [ "$stripped_output" = "$expected_output" ]
}

@test "Local: > redirection simple" {
    run "./dsh" <<EOF
echo hello, class > output.txt
cat output.txt
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="hello,classlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$status" -eq 0 ]
    [ "$stripped_output" = "$expected_output" ]
    [ -f output.txt ]
}


# REMOTE TESTS

# Constants
RDSH_DEF_PORT=1234
RDSH_DEF_SVR_INTERFACE="0.0.0.0"
RDSH_DEF_CLI_CONNECT="127.0.0.1"

# Global variables
SERVER_PID=
MULTI_THREADED=0  # Default to single-threaded

# Setup function for single-threaded tests
setup() {
    # Check if the port is already in use
    if lsof -i :${RDSH_DEF_PORT} > /dev/null; then
        echo "Port ${RDSH_DEF_PORT} is already in use. Killing existing processes..."
        fuser -k ${RDSH_DEF_PORT}/tcp
        sleep 1  # Wait for the port to be released
    fi

    # Start the server in the appropriate mode
    if [ "$MULTI_THREADED" -eq 1 ]; then
        echo "Starting server in multi-threaded mode..."
        ./dsh -s ${RDSH_DEF_SVR_INTERFACE}:${RDSH_DEF_PORT} -x &
    else
        echo "Starting server in single-threaded mode..."
        ./dsh -s ${RDSH_DEF_SVR_INTERFACE}:${RDSH_DEF_PORT} &
    fi

    SERVER_PID=$!
    sleep 1  # Give the server time to start

    # Verify that the server is running
    if ! ps -p $SERVER_PID > /dev/null; then
        echo "Server failed to start. Exiting test."
        exit 1
    fi
    echo "Server started with PID $SERVER_PID."
}

# Teardown function
teardown() {
    if ps -p $SERVER_PID > /dev/null; then
        echo "Stopping server with PID $SERVER_PID..."
        kill $SERVER_PID || kill -9 $SERVER_PID  # Force kill if necessary
        sleep 1  # Wait for the server to shut down
    else
        echo "Server PID $SERVER_PID not found. It may have already exited."
    fi
}

# Helper function for multi-threaded tests
setup_multi_threaded() {
    MULTI_THREADED=1
    setup
}


@test "Remote: Client can connect to server" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
exit
EOF
    echo "Output: $output"
    echo "Exit Status: $status"

    [ "$status" -eq 0 ]
}

@test "Remote: Execute basic ls command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
}

@test "Remote: Execute whoami command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
whoami
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "Remote: Handle empty command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF

exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
}

@test "Remote: Handle invalid command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
invalid_command
exit
EOF

    [ "$status" -eq 0 ]
}

@test "Remote: Pipe ls output into wc" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls | wc -l
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ [0-9]+ ]]
}

@test "Remote: Redirect output to file" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo 'Test Output' > test_output.txt
cat test_output.txt
exit
EOF
    echo "Output: $output"
    [[ "$output" =~ "Test Output" ]]
}

@test "Remote: Multiple commands in sequence" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo Hello
echo World
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Hello" ]]
    [[ "$output" =~ "World" ]]
}

@test "Remote: Command with arguments" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo Hello World
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Hello World" ]]
}

@test "Remote: Pipe commands" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls | grep dshlib.c
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "dshlib.c" ]]
}

@test "Remote: Output redirection to file" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo 'Remote Test Output' > remoteoutput.txt
cat remoteoutput.txt
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Remote Test Output" ]]
    [ -f remoteoutput.txt ]
}

@test "Remote: Built-in exit command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
exit
EOF

    [ "$status" -eq 0 ]
}

@test "Remote: Built-in stop-server command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
stop-server
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "client requested server to stop, stopping..." ]]
}

@test "Remote: Built-in cd command" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
cd /tmp
pwd
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "/tmp" ]]
}


@test "Remote: Long-running command" {
    run timeout 5 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
sleep 3
echo Done
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Done" ]]
}

@test "Remote: Exceeding pipe limit" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
echo test | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "rdsh-error: command execution error" ]]
}

@test "Remote: Large output" {
    run timeout 5 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
cat /usr/share/dict/words
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "a" ]]  # Check if output contains at least one word
}

@test "Remote: Command with multiple pipes" {
    run timeout 2 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
ls | grep dshlib.c | wc -l
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "1" ]]
}

@test "Remote: Command with long-running process" {
    run timeout 5 ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF
sleep 3
echo Done
exit
EOF
    echo "Output: $output"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Done" ]]
}


# EXTRA CREDIT

@test "Extra Credit: Multiple clients connecting concurrently" {
    setup_multi_threaded

    # Run two clients in the background and capture their output
    ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF > client1_output.txt &
    echo Client 1
    sleep 1
    exit
EOF
    CLIENT1_PID=$!

    ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF > client2_output.txt &
    echo Client 2
    sleep 1
    exit
EOF
    CLIENT2_PID=$!

    # Wait for both clients to finish
    wait $CLIENT1_PID
    wait $CLIENT2_PID

    # Stop the server
    if ps -p $SERVER_PID > /dev/null; then
        kill $SERVER_PID || kill -9 $SERVER_PID
    fi

    # Read client output
    CLIENT1_OUTPUT=$(cat client1_output.txt)
    CLIENT2_OUTPUT=$(cat client2_output.txt)
    echo "Client 1 Output: $CLIENT1_OUTPUT"
    echo "Client 2 Output: $CLIENT2_OUTPUT"

    # Verify output
    [[ "$CLIENT1_OUTPUT" =~ "Client 1" ]]
    [[ "$CLIENT2_OUTPUT" =~ "Client 2" ]]
}

@test "Extra Credit: Concurrent command execution" {
    setup_multi_threaded

    # Run two clients in the background and capture their output
    ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF > client1_output.txt &
    sleep 1
    echo Client 1 done
    exit
EOF
    CLIENT1_PID=$!

    ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF > client2_output.txt &
    echo Client 2 done
    exit
EOF
    CLIENT2_PID=$!

    # Wait for both clients to finish
    wait $CLIENT1_PID
    wait $CLIENT2_PID

    # Stop the server
    teardown

    # Read client output
    CLIENT1_OUTPUT=$(cat client1_output.txt)
    CLIENT2_OUTPUT=$(cat client2_output.txt)
    echo "Client 1 Output: $CLIENT1_OUTPUT"
    echo "Client 2 Output: $CLIENT2_OUTPUT"

    # Verify output
    [[ "$CLIENT1_OUTPUT" =~ "Client 1 done" ]]
    [[ "$CLIENT2_OUTPUT" =~ "Client 2 done" ]]
}

@test "Remote: Stress test with multiple clients" {
    setup_multi_threaded

    # Run 5 clients in the background and capture their output
    for i in {1..5}; do
        ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF > client${i}_output.txt &
        echo Client $i
        sleep 1
        exit
EOF
        CLIENT_PIDS[$i]=$!
    done

    # Wait for all clients to finish
    for pid in "${CLIENT_PIDS[@]}"; do
        wait $pid
    done

    # Stop the server
    teardown

    # Read and verify client output
    for i in {1..5}; do
        CLIENT_OUTPUT=$(cat client${i}_output.txt)
        echo "Client $i Output: $CLIENT_OUTPUT"
        [[ "$CLIENT_OUTPUT" =~ "Client $i" ]]
    done
}

@test "Remote: Handling client disconnections" {
    setup_multi_threaded

    # Run a client that disconnects abruptly and capture its output
    ./dsh -c ${RDSH_DEF_CLI_CONNECT}:${RDSH_DEF_PORT} <<EOF > client_output.txt &
    echo Client disconnecting
    exit
EOF
    CLIENT_PID=$!

    # Wait for the client to finish
    wait $CLIENT_PID

    # Stop the server
    teardown

    # Read client output
    CLIENT_OUTPUT=$(cat client_output.txt)
    echo "Client Output: $CLIENT_OUTPUT"

    # Verify output
    [[ "$CLIENT_OUTPUT" =~ "Client disconnecting" ]]
}