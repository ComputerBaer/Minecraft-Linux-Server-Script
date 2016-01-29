#!/bin/bash

GameStatus
if [[ $GAME_IS_RUNNING == true ]]; then
    screen -r $InstanceName
else
    echo -e "${FG_YELLOW}${STR_GAME_RUNNING_NOT}${RESET_ALL}"
fi
