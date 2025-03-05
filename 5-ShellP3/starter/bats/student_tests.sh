#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

# Test 1: ls
@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="batsdshdsh_cli.cdshlib.cdshlib.hmakefiledsh3>dsh3>cmdloopreturned0"

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

# Test 2: Single command with no arguments
@test "Echo test with no arguments" {
    run "./dsh" <<EOF
echo
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="dsh3>dsh3>cmdloopreturned0"

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

# Test 3: Command with multiple arguments
@test "Echo with arguments" {
    run "./dsh" <<EOF
echo Hello World
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="HelloWorlddsh3>dsh3>cmdloopreturned0"

     echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    
    # Check if the correct output is printed
    [ "$status" -eq 0 ]
    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

# Test 5: Empty input
@test "Empty input" {
    run "./dsh" <<EOF
<EOF>
EOF

    # Ensure no output and status is 0 (exit gracefully)
    [ "$status" -eq 0 ]
}

# Test 6: Command with invalid syntax
@test "Invalid command syntax" {
    run "./dsh" <<EOF
ls | | grep dshlib.c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="dsh3>warning:nocommandsprovideddsh3>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

# Test 7: Multiple commands with pipe (ls | grep | wc)
@test "Multiple command pipe" {
    run "./dsh" <<EOF
ls | grep dshlib.c | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="1dsh3>dsh3>cmdloopreturned0"

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

# Test 8: Built-in command (exit)
@test "Built-in exit command" {
    run "./dsh" <<EOF
exit
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for eas
    expected_output="dsh3>exiting..."

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

@test "Invalid second command" {
    run "./dsh" <<EOF
ls | awesomecommand
EOF
    
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvp:Permissiondenieddsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

# Test 13: Check for prompt format
@test "Prompt format" {
    run "./dsh" <<EOF
echo Test
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="Testdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}
# Test 11: Multiple commands, no pipes
@test "Multiple commands (without pipe)" {
    run "./dsh" <<EOF
echo Hello
echo World
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="HelloWorlddsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

# Test 12: Error case - invalid command
@test "Invalid command execution" {
    run "./dsh" <<EOF
nonexistentcommand
EOF
    
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="execvp:Permissiondenieddsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Check if output is valid for wc
    [ "$status" -eq 0 ]
}

# Test 14: Exceeding the pipe limit
@test "Exceeding pipe limit" {
    run "./dsh" <<EOF
echo test | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat | cat
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Replace %d with the actual limit your shell enforces
    expected_output="dsh3>error:pipinglimitedto8commandsdsh3>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match (modify if necessary)
    [ "$stripped_output" = "$expected_output" ]

    # Check if exit status is nonzero (indicating an error)
    [ "$status" -eq 0 ]
}

@test "Sleep command" {
    run "./dsh" <<EOF
sleep 3
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$status" -eq 0 ]
    [ "$stripped_output" = "$expected_output" ]
}

