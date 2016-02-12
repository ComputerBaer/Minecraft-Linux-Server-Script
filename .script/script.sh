#!/bin/bash

# CheckAdditionalDependencies Function
function CheckAdditionalDependencies
{
    # Check Dependencies
    local dependencies=""
    if [[ $(IsInstalled screen) == false ]]; then
        dependencies="${dependencies} screen"
    fi
    if [[ $(IsInstalled java) == false ]]; then
        if [[ $SYSTEM_PACKAGE_MANAGER == "yum" ]]; then
            dependencies="${dependencies} java-1.8.0-openjdk.x86_64"
        elif [[ $SYSTEM_PACKAGE_MANAGER == "zypper" ]]; then
            dependencies="${dependencies} java-1_8_0-openjdk"
        else # apt-get
            dependencies="${dependencies} openjdk-8-jre"
        fi
    fi

    # Check Bukkit/Spigot Dependencies
    if [[ $ServerType == "bukkit" ]] || [[ $ServerType == "spigot" ]]; then
        if [[ $(IsInstalled git) == false ]]; then
            dependencies="${dependencies} git"
        fi
    fi

    # Missing Dependencies found?
    if [[ -z $dependencies ]]; then
        return
    fi
    echo -e "${FG_RED}${STR_DEPENDENCIES_MISSING/'{0}'/${dependencies:1}}${RESET_ALL}"

    # Is root user
    if [[ $SYSTEM_IS_ROOT == true ]] && [ ! -z "$SYSTEM_PACKAGE_MANAGER" ]; then
        # Install missing Dependencies?
        echo -e "${FG_YELLOW}${STR_DEPENDENCIES_INSTALL}${RESET_ALL}"
        if [[ $(DialogYesNo) == true ]]; then
            echo # Line break
            $SYSTEM_PACKAGE_MANAGER $SYSTEM_PACKAGE_MANAGER_INSTALL $dependencies
            echo # Line break
            return
        fi
    fi

    ExitScript
}

# CompleteInit Function
function CompleteInit
{
    return # Empty Function
}

# CompleteCleanUp Function
function CompleteCleanUp
{
    return # Empty Function
}
