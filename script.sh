#!/usr/bin/env bash
# ==============================================================================
# Ptyxis Background Opacity Editor
# By Adriano Paonessa (https://www.github.com/adrianopaonessa/)
# 
# Description: This script allows users to modify the background opacity of
#              Ptyxis terminal profiles either interactively or via command-line
#              arguments. It supports both direct parameter usage and an
#              interactive mode for user-friendly operation.
#
# Usage:
#   Interactive mode: ./script.sh
#   Direct mode:      ./script.sh -uuid <UUID> -opacity <0-100>
#   Help:             ./script.sh -h or --help
#
# Dependencies: bash, dconf, awk
# ==============================================================================

# Function to display usage information
show_usage() {
    echo "Usage: $0 [-uuid <UUID>] [-opacity <0-100>]"
    echo "Modify Ptyxis profile opacity directly or interactively"
    echo ""
    echo "Options:"
    echo "  -uuid <UUID>      Specify the profile UUID to modify"
    echo "  -opacity <0-100>  Set the opacity value (0-100)"
    echo "  -h, --help        Show this help message"
    exit 1
}

# Variables to store command-line parameters
uuid_value=""
opacity_value=""

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -uuid)
            uuid_value="$2"
            # Validate that UUID parameter is not empty
            if [[ -z "$uuid_value" ]]; then
                echo "Error: UUID value cannot be empty."
                show_usage
            fi
            shift
            shift
            ;;
        -opacity)
            opacity_value="$2"
            # Validate that opacity parameter is not empty
            if [[ -z "$opacity_value" ]]; then
                echo "Error: Opacity value cannot be empty."
                show_usage
            fi
            shift
            shift
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Error: Unknown parameter: $1"
            show_usage
            ;;
    esac
done

# If both parameters are provided, apply changes directly without interactive mode
if [[ -n "$uuid_value" && -n "$opacity_value" ]]; then
    # Validate opacity value is a number between 0 and 100
    if ! [[ "$opacity_value" =~ ^[0-9]+$ ]] || [ "$opacity_value" -lt 0 ] || [ "$opacity_value" -gt 100 ]; then
        echo "Error: Invalid opacity value. Must be a number between 0 and 100."
        exit 1
    fi

    # Convert percentage to decimal (0.0-1.0) for dconf
    opacity=$(awk -v p="$opacity_value" 'BEGIN { printf "%.2f", p/100 }')
    
    echo "Setting opacity $opacity for profile $uuid_value"
    # Write the new opacity value to dconf
    dconf write "/org/gnome/Ptyxis/Profiles/$uuid_value/opacity" "$opacity"
    echo ">>> Success! Opacity has been updated. <<<"
    exit 0
fi

# ==============================================================================
# INTERACTIVE MODE
# This section runs if no command-line parameters are provided
# ==============================================================================

echo ">>> Welcome to the Ptyxis Background Opacity Editor <<<"
echo

# Retrieve the default profile UUID from dconf
default_uuid=$(dconf read /org/gnome/Ptyxis/default-profile-uuid | tr -d \')
echo "- Default profile UUID: $default_uuid"

# Prompt user to edit the default profile or choose another
read -p "> Do you want to edit this profile? (Y/n): " choice
choice=${choice:-y}  # Set default choice to 'y' if empty

selected_uuid=""
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    # Use the default profile UUID
    selected_uuid="$default_uuid"
elif [[ "$choice" == "n" || "$choice" == "N" ]]; then
    echo
    echo "> Available profiles:"
    
    # List all available profiles from dconf
    profiles=$(dconf list /org/gnome/Ptyxis/Profiles/)
    
    i=1
    declare -A uuid_map  # Associative array to map numbers to UUIDs
    
    # Display each profile with a number for selection
    for p in $profiles; do
        uuid=$(echo "$p" | tr -d '/')
        pLabel=$(dconf read "/org/gnome/Ptyxis/Profiles/$uuid/label" | tr -d '/')
        echo "  $i) $pLabel [$uuid]"
        uuid_map[$i]=$uuid
        ((i++))
    done

    # Add option to manually enter a UUID
    echo "  $i) Enter UUID manually"

    echo
    read -p "Choose a profile number: " num

    # Validate profile number selection
    if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt $i ]; then
        echo "Error: Invalid selection. Exiting."
        exit 1
    fi

    if [[ "$num" -eq "$i" ]]; then
        # Manual UUID entry
        read -p "Enter UUID manually: " selected_uuid
    else
        # Use selected profile UUID
        selected_uuid=${uuid_map[$num]}
    fi
else
    echo "Error: Invalid choice. Exiting."
    exit 1
fi

# Validate that a UUID was selected
if [[ -z "$selected_uuid" ]]; then
    echo "Error: No profile UUID selected."
    exit 1
fi

echo
read -p "Enter opacity value (0-100): " percent

# Validate opacity input
if ! [[ "$percent" =~ ^[0-9]+$ ]] || [ "$percent" -lt 0 ] || [ "$percent" -gt 100 ]; then
    echo "Error: Invalid value. Must be a number between 0 and 100."
    exit 1
fi

# Convert percentage to decimal (0.0-1.0) for dconf
opacity=$(awk -v p="$percent" 'BEGIN { printf "%.2f", p/100 }')

echo "Setting opacity $opacity for profile $selected_uuid"
# Write the new opacity value to dconf
dconf write "/org/gnome/Ptyxis/Profiles/$selected_uuid/opacity" "$opacity"

echo ">>> Success! Opacity has been updated. <<<"