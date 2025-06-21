#!/bin/bash
# Shell authon: yu13140 <whmyc801@gmail.com>
# 20250621

if [ ! -f "$1" ]; then
    echo "Usage: $0 <compile_output_file>"
    exit 1
fi

file_list=$(mktemp)
zip_name="error_sources.zip"

grep -oP 'Error 1[^\[]*\[\K[^:]*\.[oO]' "$1" | while read -r obj_file; do    
    for ext in c cpp cc cxx S; do
        source_file="${obj_file%.*}.$ext"

        if [ -f "$source_file" ]; then
            echo "$source_file" >> "$file_list"
            break
        elif [ -f "../$source_file" ]; then
            echo "../$source_file" >> "$file_list"
            break
        fi
    done
done

if [ -s "$file_list" ]; then
    echo "Found error source files. Packaging to $zip_name..."
    xargs -a "$file_list" zip -q "$zip_name"
    echo "ZIP file created: $zip_name"
else
    echo "No error source files found in the build output"
fi

rm -f "$file_list"