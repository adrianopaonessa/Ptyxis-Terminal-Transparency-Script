# Ptyxis Background Opacity Editor

A Bash script to easily modify the background opacity of Ptyxis terminal profiles either interactively or via command-line arguments.

## Features

- **Interactive Mode**: User-friendly interface to select profiles and set opacity
- **Direct Mode**: Command-line options for scripting and automation
- **Validation**: Comprehensive input validation for UUIDs and opacity values
- **Flexible**: Supports both default profile selection and manual UUID entry

## Requirements

- Bash shell
- Dconf configuration system (standard on GNOME-based systems)
- Ptyxis terminal emulator
- awk (usually pre-installed on most systems)

## Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/adrianopaonessa/Ptyxis-Terminal-Transparency-Script/refs/heads/main/script.sh
```

2. Make the script executable:
```bash
chmod +x script.sh
```

3. (Optional) Move to a directory in your PATH for global access:
```bash
sudo mv script.sh /usr/local/bin/ptysis-opacity-editor
```

## Usage

### Interactive Mode
Run the script without arguments for interactive mode:
```bash
./script.sh
```

### Direct Mode
Use command-line arguments for direct control:
```bash
./script.sh -uuid "your-profile-uuid" -opacity 75
```

### Help
Display usage information:
```bash
./script.sh -h
```

## Examples

1. Set specific opacity for a specific profile UUID:
```bash
./script.sh -uuid "a1b2c3d4-1234-5678-90ab-cdef01234567" -opacity 50
```

2. Use interactive mode to browse and select from available profiles:
```bash
./script.sh
```

## How It Works

The script modifies the opacity setting in Ptyxis's dconf configuration. It:
1. Retrieves available profile UUIDs from dconf
2. Validates input parameters
3. Converts percentage values (0-100) to decimal (0.0-1.0) format
4. Writes the new value to the appropriate dconf key

## Common Profile UUIDs

Ptyxis uses UUIDs to identify profiles. Common built-in profiles include:
- Default profile: often the first one listed
- You can find your profile UUIDs by examining:
  ```bash
  dconf list /org/gnome/Ptyxis/Profiles/
  ```
  or inside the ```profiles``` tab in the terminal settings.

## Notes

- Opacity values range from 0 (completely transparent) to 100 (completely opaque)
- Changes take effect immediately in new terminal windows
- Existing terminal windows may need to be restarted to reflect changes

## Troubleshooting

1. If you get permission errors, ensure you have write access to dconf settings
2. If the script doesn't find any profiles, verify Ptyxis is installed
3. For invalid UUID errors, check the profile exists using:
   ```bash
   dconf read /org/gnome/Ptyxis/Profiles/your-uuid-here/label
   ```

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## Support

If you find this tool helpful, please give it a star ⭐ on GitHub!

---

*This tool is not officially affiliated with Ptyxis or GNOME.*
