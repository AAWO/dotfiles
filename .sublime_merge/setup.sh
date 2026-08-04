#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ ! -z "$1" ]; then
   # Manually specified path
   subl_path="$1"
elif [[ "$OSTYPE" == "darwin"* ]]; then
   # MacOS
   subl_path="$HOME/Library/Application Support/Sublime Merge/Packages"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
   # Linux
   subl_path="$HOME/.config/sublime-merge/Packages"
elif [[ "$OSTYPE" == "cygwin" ]]; then
   # Cygwin on Windows
   subl_path="%APPDATA%\Sublime Text\Packages"
elif [[ "$OSTYPE" == "msys" ]]; then
   # MinGW/Git Bash/msysGit Windows
   subl_path="%APPDATA%\Sublime Text\Packages"
else
   # Unknown or not supported
   echo "Unknown or not supported OS detected: $OSTYPE"
   exit 1
fi

# check if directory exists
if [ ! -d "$subl_path" ]; then
   echo "Directory: '$subl_path' doesn't exist."
   echo "Please specify the path manually as a script argument."
   exit 1
else
   echo "Found directory '$subl_path'"
fi

src_dir="$SCRIPT_DIR/User"
tgt_dir="$subl_path/User"

# check if target User directory is empty
if [ ! -z "$( ls -A "$tgt_dir" )" ]; then
   echo "Directory '$tgt_dir' is not empty. Moving contents to '$SCRIPT_DIR/User_backup'." 
   mv "$tgt_dir" "$SCRIPT_DIR/User_backup"
fi

echo "Creating a symlink: '$src_dir' -> '$tgt_dir'"
ln -s "$src_dir" "$tgt_dir"
