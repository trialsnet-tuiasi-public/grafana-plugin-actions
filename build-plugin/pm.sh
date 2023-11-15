#!/bin/bash

# Check if command argument is provided
if [ "$1" = "" ]; then
	echo "Please provide a command to run."
	exit 1
fi

# Detect the package manager
if [ -f yarn.lock ]; then
	pm="yarn"
elif [ -f pnpm-lock.yaml ]; then
	pm="pnpm"
elif [ -f package-lock.json ]; then
	pm="npm"
else
	echo "No recognized package manager found in this project."
	exit 1
fi

# Run the provided command with the detected package manager
echo "Running '$1' with $pm..."
if [ "$1" = "install" ]; then
	"$pm" install
elif [ "$pm" = "npm" ] || [ "$pm" = "pnpm" ]; then
	"$pm" run "$1"
else
	"$pm" "$1"
fi
