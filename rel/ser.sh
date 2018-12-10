#!/bin/bash
check_update () {
    echo "Checking update"
}

reinstall_theme () {
    echo "Reinstalling theme"
}

while true; do
    options=("Check for update" "Reinstall theme" "Quit")

    echo "Choose an option: "
    select opt in "${options[@]}"; do
        case $REPLY in
            1) check_update; break ;;
            2) reinstall_theme; break ;;
            3) break 2 ;;
            *) echo "What's that?" >&2
        esac
    done
done

echo "Bye bye!"
