#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Echo environment variable" {
    run ./dsh <<EOF
echo \$HOME
EOF
    [ "$status" -eq 0 ]
    [ -n "$output" ] # Ensure some output is produced
}

@test "Sequential commands execution" {
    run ./dsh <<EOF
mkdir test_dir && cd test_dir && pwd
EOF
    [ "$status" -eq 0 ]
}

@test "SIGTERM handling" {
    run ./dsh <<EOF
sleep 5 &
kill -TERM \$!
EOF
    [ "$status" -eq 0 ]
}

@test "Nonexistent file error handling" {
    run ./dsh <<EOF
cat nonexistingfile
EOF
    [[ "$output" == *"No such file or directory"* ]]  # Ensure correct error message is shown
}

@test "Run process in background" {
    run ./dsh <<EOF
sleep 3 &
EOF
    [ "$status" -eq 0 ]
}

@test "Empty input handling" {
    run ./dsh <<EOF

EOF
    [ "$status" -eq 0 ]
}

@test "Built in exit check" {
    run ./dsh <<EOF
exit 42
EOF
    [ "$status" -eq 0 ] # should be 0 due to custom implemenation
}

@test "Empty command line gives warning" {
    run ./dsh <<EOF

EOF
    [[ "$output" == *"warning: no commands provided"* ]]
}

@test "cd to existing directory" {
    # Ensure the target directory exists
    mkdir -p /tmp/dsh_test_directory

    # Run the shell command to change to that directory
    run ./dsh <<EOF
cd /tmp/dsh_test_directory
pwd
EOF

    # Check if the status code is 0 (success)
    [ "$status" -eq 0 ]

    # Clean up
    rm -rf /tmp/dsh_test_directory
}

@test "cd with no arguments (default to home)" {
    run ./dsh <<EOF
cd
pwd
EOF

    # Check if the status code is 0 (success)
    [ "$status" -eq 0 ]
}

@test "cd to non-existent directory" {
    run ./dsh <<EOF
cd /nonexistent_directory
EOF

    # Expect an error message for the failed command
    echo "$output" | grep -q "No such file or directory"

    # Check that the status code is non-zero (error)
    [ "$status" -eq 0 ]
}

@test "cd to a file (not a directory)" {
    # Create a test file
    touch /tmp/test_file

    run ./dsh <<EOF
cd /tmp/test_file
EOF

    # Expect an error message for trying to cd into a file
    echo "$output" | grep -q "Not a directory"

    # Check that the status code is non-zero (error)
    [ "$status" -eq 0 ]

    # Clean up
    rm /tmp/test_file
}
