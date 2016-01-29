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

    # Download Serverfile
    echo -ne "${FG_YELLOW}${STR_GAME_INSTALL_START}${RESET_ALL}"
    curl -s $GAME_DL_URL -o $GAME_EXECUTABLE &
    WaitForBackgroundProcess $! $FG_YELLOW

    # Check Serverfile size
    local size=$(stat --format=%s $GAME_EXECUTABLE)
    if [ $size -lt 1000 ]; then
        echo -e "${FG_RED}${STR_GAME_INSTALL_FAILED}${RESET_ALL}"
        return
    fi
    echo -e "${FG_GREEN}${STR_GAME_INSTALL_DONE}${RESET_ALL}"

    # Check Minecraft EULA
    CheckEula
}

# StartGame Function
function StartGame
{
    if [ ! -d $GAME_DIR ]; then
        return
    fi

    # Check Minecraft EULA
    CheckEula

    # Check Server Status
    GameStatus
    if [[ $GAME_IS_RUNNING == true ]]; then
        echo -e "${FG_RED}${STR_GAME_ALREADY_RUNNING}${RESET_ALL}"
        ExitScript
    fi
    echo -e "${FG_YELLOW}${STR_GAME_START}${RESET_ALL}"

    local EXEC_DIR=$(dirname $GAME_EXECUTABLE)
    local EXEC_NAME=$(basename $GAME_EXECUTABLE)
    local params="-Xmx${MaxMemory} -Xms${MinMemory} -jar ${EXEC_NAME} nogui"

    # Start Server
    cd $EXEC_DIR
    screen -A -m -d -S $InstanceName java $params
    cd $SCRIPT_BASE_DIR
}

# StopGame Function
function StopGame
{
    GameStatus
    if [[ $GAME_IS_RUNNING == true ]]; then
        screen -S $InstanceName -p 0 -X stuff "stop$(echo -ne '\r')"
    fi

    echo -e "${FG_YELLOW}${STR_GAME_STOPPED}${RESET_ALL}"
}

# GameStatus Function
function GameStatus
{
    if screen -list | grep -q $InstanceName; then
        GAME_IS_RUNNING=true
    else
        local EXEC_NAME=$(basename $GAME_EXECUTABLE)
        local PROCESS_IDS=$(pgrep -f $EXEC_NAME)

        if [[ ! -z $PROCESS_IDS ]]; then
            GAME_IS_RUNNING=true
        fi

        GAME_IS_RUNNING=false
    fi
}

# BackupGame Function
function BackupGame
{
    if [ ! -d $GAME_DIR ]; then
        return
    fi

    local DATE=$(date +%Y-%m-%d_%H-%M-%S)
    local BACKUP_FILE="${SCRIPT_BACKUP_DIR}${DATE}.tgz"

    if [ ! -d $SCRIPT_BACKUP_DIR ]; then
        mkdir -p $SCRIPT_BACKUP_DIR
    fi

    # /
    # - configuration.ini
    local files="${SCRIPT_CONFIG}"
    # /game/
    # - *
    files="${files} ${GAME_DIR}*"

    # *
    # - *.jar
    local excludes="--exclude=*.jar"
    # /game/logs/
    # - *.gz
    excludes="${excludes} --exclude=${GAME_DIR}logs/*.gz"

    tar -czf $BACKUP_FILE $excludes $files 2> /dev/null &
    WaitForBackgroundProcess $! $FG_YELLOW
}
