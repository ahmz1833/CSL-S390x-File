#!/bin/sh
set -e

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Cannot determine the Linux distribution. Exiting."
    exit 1
fi

# Set assembler and compiler based on the distribution
if [ "$DISTRO" = "arch" ]; then
    AS="s390x-linux-as"
    LD="s390x-linux-ld" 
else
    AS="s390x-linux-gnu-as"
    LD="s390x-linux-gnu-ld"
fi

# Assemble the source file
$AS -o tmp.o main.S

# Link the object file
$LD -o main.out tmp.o

# Remove the object file
rm tmp.o

# Run the program
qemu-s390x ./main.out
