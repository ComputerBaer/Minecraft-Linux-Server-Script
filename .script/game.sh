#!/bin/bash

GAME_IS_RUNNING=false

# CheckEula Function
function CheckEula
{
    eula=false
    if [ -f $GAME_EULA ]; then
        source $GAME_EULA
    fi
    eula=$(CheckBoolean $eula false)

    if [[ $eula == true ]]; then
        return
    fi

    echo -e "${FG_YELLOW}${STR_GAME_EULA}${RESET_ALL}"
    echo -e "${FG_YELLOW}${GAME_EULA_URL}${RESET_ALL}"
    if [[ $(DialogYesNo) == true ]]; then
        echo "eula=true" > $GAME_EULA
    fi
}

# InstallGame Function
function InstallGame
{
    if [ ! -d $GAME_DIR ]; then
        mkdir -p $GAME_DIR
    fi

    if [ -f $GAME_EXECUTABLE ]; then
        rm $GAME_EXECUTABLE
    fi

    echo -e "${FG_YELLOW}${STR_GAME_INSTALL_START}${RESET_ALL}"
    curl -s $GAME_DL_URL -o $GAME_EXECUTABLE &
    WaitForBackgroundProcess $! $FG_YELLOW

    local size=$(stat --format=%s $GAME_EXECUTABLE)
    if [ $size -lt 1000 ]; then
        echo -e "${FG_RED}${STR_GAME_INSTALL_FAILED}${RESET_ALL}"
        return
    fi
    echo -e "${FG_GREEN}${STR_GAME_INSTALL_DONE}${RESET_ALL}"

    CheckEula
}

# StartGame Function
function StartGame
{
    return # Empty Function
}

# StopGame Function
function StopGame
{
    return # Empty Function
}

# GameStatus Function
function GameStatus
{
    return # Empty Function
}

# BackupGame Function
function BackupGame
{
    return # Empty Function
}
