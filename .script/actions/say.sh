#!/bin/bash

GameStatus
if [[ $GAME_IS_RUNNING == true ]]; then
    # Remove "say "-Prefix
    text=${SCRIPT_PARAMETER:4}

    # Show and send text
    echo $text
    screen -S $InstanceName -p 0 -X stuff "say ${text}$(echo -ne '\r')"
else
    echo -e "${FG_YELLOW}${STR_GAME_RUNNING_NOT}${RESET_ALL}"
fi
