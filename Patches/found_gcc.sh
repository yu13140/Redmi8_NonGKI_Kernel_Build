#!/usr/bin/env bash
# Shell authon: JackA1ltman <cs2dtzq@163.com>
# 20250610

find_gcc_prefix() {
    local toolchain_bin_dir="$1"
    local possible_prefixes=()

    if [ ! -d "$toolchain_bin_dir" ]; then
        echo "Error: Folder '$toolchain_bin_dir' not existed。" >&2
        return 1
    fi

    for gcc_path in "$toolchain_bin_dir"/*elfedit; do
        if [ -x "$gcc_path" ] && [ -f "$gcc_path" ]; then
            filename=$(basename "$gcc_path")
            prefix="${filename%elfedit}"
            if [ -n "$prefix" ]; then
                possible_prefixes+=("$prefix")
            fi
        fi
    done

    if [ ${#possible_prefixes[@]} -eq 0 ]; then
        echo "Warning: In '$toolchain_bin_dir' not found execuate file with 'elfedit'." >&2
        return 1
    fi

    if [ ${#possible_prefixes[@]} -eq 1 ]; then
        echo "${possible_prefixes[0]}"
        return 0
    fi

    local max_len=0
    local best_prefix=""
    for p in "${possible_prefixes[@]}"; do
        if (( ${#p} > max_len )); then
            max_len=${#p}
            best_prefix="$p"
        elif (( ${#p} < max_len )); then
            best_prefix="$p"
            : # No-op
        fi
    done

    echo "$best_prefix"
    return 0
}

# Main

if [ "$1" == "GCC_64" ]; then
    SET="$GITHUB_WORKSPACE/gcc-64/bin"
    REAL_PREFIX=$(find_gcc_prefix "$SET")
    echo "GCC_64=CROSS_COMPILE=$GITHUB_WORKSPACE/gcc-64/bin/$REAL_PREFIX" >> $GITHUB_ENV
elif [ "$1" == "GCC_32" ]; then
    SET="$GITHUB_WORKSPACE/gcc-32/bin"
    REAL_PREFIX=$(find_gcc_prefix "$SET")
    echo "GCC_32=CROSS_COMPILE_ARM32=$GITHUB_WORKSPACE/gcc-32/bin/$REAL_PREFIX" >> $GITHUB_ENV
elif [ "$1" == "GCC_32_ONLY" ]; then
    SET="$GITHUB_WORKSPACE/gcc-32/bin"
    REAL_PREFIX=$(find_gcc_prefix "$SET")
    echo "GCC_32=CROSS_COMPILE=$GITHUB_WORKSPACE/gcc-32/bin/$REAL_PREFIX" >> $GITHUB_ENV
fi
