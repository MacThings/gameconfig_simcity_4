#!/bin/bash
#

gamename="simcity4"

function _helpDefaultRead()
{
    VAL=$1

    if [ ! -z "$VAL" ]; then
        defaults read "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "$VAL"
    fi
}

function _helpDefaultWrite()
{
    VAL=$1
    local VAL1=$2

    if [ ! -z "$VAL" ] || [ ! -z "$VAL1" ]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "$VAL" "$VAL1"
    fi
}

ScriptHome=$(echo $HOME)
MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

cd ../../../../SimCity\ 4.app
plist="Contents/Info.plist"

wrapperpath=$( PWD )
_helpDefaultWrite "WrapperPath" "$wrapperpath"

function _get_cores()
{

    cores=$( sysctl -n hw.ncpu )
    _helpDefaultWrite "PhysicalCores" "$cores"
    rm /private/tmp/cpucores
    die() {
        echo $cores >&2
        exit 1;
    }
    for i in $(seq $cores -1 1); do
        echo "$i" >> /private/tmp/cpucores
    done

}

function _check_for_game()
{

    if [ -f "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/Apps/SimCity 4.exe" ]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameInstalled" -bool TRUE
    else
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameInstalled" -bool FALSE
    fi

}

function _setup_exe()
{

    setup_exe=$( _helpDefaultRead "SetupExe" )
    setup_pid=$( _helpDefaultRead "SetupPID" )

    echo "\"Z:$setup_exe\"" > "Contents/Resources/drive_c/preinstall.bat"
    echo "\"C:\\4gb_patch.exe\" \"C:\\GOG Games\\SimCity 4 Deluxe Edition\\Apps\\SimCity 4.exe\"" >> "Contents/Resources/drive_c/preinstall.bat"
    open "../SimCity 4.app"
    sleep 10
    
    wine_pid=$( ps -A |grep "preinstall.bat" |grep -v grep |awk '{print $1}' |head -n 1 )
    lsof -p $wine_pid +r 1 &>/dev/null
    
    selected_cores=$( _helpDefaultRead "SelectedCores" )
    priority=$( _helpDefaultRead "Priority" )
    width=$( _helpDefaultRead "Width" )
    height=$( _helpDefaultRead "Height" )
    
    if [[ "$priority" = "1" ]]; then
        priority="Low"
    elif [[ "$priority" = "2" ]]; then
        priority="Normal"
    else
        priority="High"
    fi
    
    flag="-w -CustomResolution:enabled -r"$width"x"$height"x32 -CPUCount:"$selected_cores" -CPUPriority:"$priority" -l:english"
    #/usr/libexec/PlistBuddy -c "Set Program\ Flags $flag" "$plist"

    echo "start \"\" \"C:\\GOG Games\\SimCity 4 Deluxe Edition\\Apps\\SimCity 4.exe\" $flag" > "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/start.bat"
    
    cp autosave.exe "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition"
    
    game_exe="/GOG Games/SimCity 4 Deluxe Edition/start.bat"
    /usr/libexec/PlistBuddy -c "Set Program\ Name\ and\ Path $game_exe" "$plist"
    
    kill -kill "$setup_pid" && open ../Game\ Config*.app

}

function _check_nammod()
{

    check_nammod_1=$( find ~/Documents/SimCity\ 4/Plugins -name "NetworkAddonMod_Props.dat" )
    check_nammod_2=$( find ~/Documents/SimCity\ 4/Plugins -name "NetworkAddonMod_BaseContent.dat" )
    check_nammod_3=$( find ~/Documents/SimCity\ 4/Plugins -name "NetworkAddonMod_UI.dat" )

    if [[ "$check_nammod_1" != "" ]] && [[ "$check_nammod_2" != "" ]] && [[ "$check_nammod_3" != "" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "NamModInstalled" -bool TRUE
    else
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "NamModInstalled" -bool FALSE
    fi

}

function _check_installed_mods()
{

osascript <<EOD
tell application "TextEdit"
    set windowCount to number of windows
    repeat with x from 1 to windowCount
        set docName to (name of document of window x)
        if (docName is equal to "sc4_mods_to_install.txt") then
            close window x
        end if
    end repeat
end tell
EOD
    
    leeched_path=$( echo "$HOME/Documents/SimCity 4" )
    cd "$leeched_path"
    
    check=$( pbpaste |sed -e 's/.*http/http/g' |uniq )

    if [ ! -f "mods_installed.txt" ]; then
        touch "mods_installed.txt"
    fi
    
    if [ -f "/private/tmp/sc4_mods_to_install.txt" ]; then
        rm "/private/tmp/sc4_mods_to_install.txt"
    fi

    while read -r line
    do

    line=$( echo "$line" |grep "http" )

    if ! grep -Fxq "$line" mods_installed.txt; then
        echo "$line" >> /private/tmp/sc4_mods_to_install.txt
        echo "$line" >> mods_installed.txt
        if [[ "$line" = "" ]]; then
            sed -i '' -e '$ d' /private/tmp/sc4_mods_to_install.txt
            sed -i '' -e '$ d' mods_installed.txt
        fi
    fi

    done <<< "$check"

    echo " "
    
    if [ -f "/private/tmp/sc4_mods_to_install.txt" ]; then
        echo -e "\n\nYou will see this missing url(s) only one time! Please make sure to download and install these Package(s) really. They will never be shown again!" >> /private/tmp/sc4_mods_to_install.txt
        open -a TextEdit /private/tmp/sc4_mods_to_install.txt
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "ModsInstalled" -bool TRUE
    fi
}

function _play()
{

    game_exe="/GOG Games/SimCity 4 Deluxe Edition/start.bat"
    /usr/libexec/PlistBuddy -c "Set Program\ Name\ and\ Path $game_exe" "$plist"
    open "../SimCity 4.app"
    
}

function _run_check()
{

    get_tasks=$( ps ax )
    
    task=$( echo "$get_tasks" |grep "SimCity 4.exe" |grep -v grep )
    task2=$( echo "$get_tasks" |grep "Z:/" |grep -v grep )
    task3=$( echo "$get_tasks" |grep "wine" |grep -v grep )
    
    if [[ "$task" != "" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameRunning" -bool TRUE
    else
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameRunning" -bool FALSE
        pkill -9 -f "autosave.EXE"
    fi

    if [[ "$task" = "" ]] && [[ "$task2" != "" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameRunning" -bool TRUE
    fi
    
    if [[ "$task" = "" ]] && [[ "$task2" = "" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameRunning" -bool FALSE
        #pkill -9 -f wine
    fi
    
    if [[ "$task3" = "" ]]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameRunning" -bool FALSE
    else
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameRunning" -bool TRUE
    fi

}

function _load_exe()
{
    
    load_exe=$( _helpDefaultRead "LoadExe" )
    load_exe_name=$( echo "$load_exe" |sed 's/.*\///g' )
    load_exe_path=$( echo "$load_exe" |sed "s/\/$load_exe_name//g" )
    
    if [[ "$load_exe" = *"NetworkAddonMod_Setup"* ]]; then
        echo "Z:" > "Contents/Resources/drive_c/loadexe.bat"
        echo "cd \"$load_exe_path\"" >> "Contents/Resources/drive_c/loadexe.bat"
        echo "\"$load_exe_name\"" >> "Contents/Resources/drive_c/loadexe.bat"
    else
        echo "\"Z:$load_exe\"" > "Contents/Resources/drive_c/loadexe.bat"
    fi
    
    /usr/libexec/PlistBuddy -c "Set Program\ Name\ and\ Path loadexe.bat" "$plist"
    open "../SimCity 4.app"
}



function _kill_autosave()
{

    pkill -f "autosave.exe"
    
}

function _kill_wine()
{

    pkill -9 -f "SimCity 4.exe"
    pkill -9 -f "autosave.EXE"
    
}

function _save_config()
{

    selected_cores=$( _helpDefaultRead "SelectedCores" )
    priority=$( _helpDefaultRead "Priority" )
    language=$( _helpDefaultRead "Language" )
    custom=$( _helpDefaultRead "Custom" )
    width=$( _helpDefaultRead "Width" )
    height=$( _helpDefaultRead "Height" )
    fullscreen=$( _helpDefaultRead "Fullscreen" )
    intro=$( _helpDefaultRead "Intro" )
    retina=$( _helpDefaultRead "Retina" )
    autosave=$( _helpDefaultRead "Autosave" )
    
    saveinterval=$( _helpDefaultRead "SaveInterval" )
    saveinterval=$( echo "$saveinterval" | sed -e 's/\..*//g' -e 's/,.*//g' )

    if [[ "$custom" = "1" ]]; then
        width="$width" height="$height"
    else
        ######### Resolution Table #########
        resolution=$( _helpDefaultRead "Resolution" )

        if [[ "$resolution" = "2" ]]; then
            width="800" height="600"
        elif [[ "$resolution" = "3" ]]; then
            width="1024" height="768"
        elif [[ "$resolution" = "4" ]]; then
            width="1280" height="960"
        elif [[ "$resolution" = "5" ]]; then
            width="1400" height="1050"
        elif [[ "$resolution" = "6" ]]; then
            width="1440" height="1080"
        elif [[ "$resolution" = "7" ]]; then
            width="1600" height="1200"
        elif [[ "$resolution" = "8" ]]; then
            width="1856" height="1392"
        #####################################
        elif [[ "$resolution" = "11" ]]; then
            width="1024" height="576"
        elif [[ "$resolution" = "12" ]]; then
            width="1152" height="648"
        elif [[ "$resolution" = "13" ]]; then
            width="1280" height="720"
        elif [[ "$resolution" = "14" ]]; then
            width="1366" height="768"
        elif [[ "$resolution" = "15" ]]; then
            width="1600" height="900"
        elif [[ "$resolution" = "16" ]]; then
            width="1920" height="1080"
        elif [[ "$resolution" = "17" ]]; then
            width="2560" height="1440"
        elif [[ "$resolution" = "18" ]]; then
            width="3840" height="2160"
        #####################################
        elif [[ "$resolution" = "19" ]]; then
            width="1280" height="800"
        elif [[ "$resolution" = "20" ]]; then
            width="1440" height="900"
        elif [[ "$resolution" = "21" ]]; then
            width="1680" height="1050"
        elif [[ "$resolution" = "22" ]]; then
            width="1920" height="1200"
        elif [[ "$resolution" = "23" ]]; then
            width="2560" height="1600"
        fi
        #####################################
    fi
    
    
    ######### Language Table #########
    if [[ "$language" = "1" ]]; then
        language="danish"
    elif [[ "$language" = "2" ]]; then
        language="dutch"
    elif [[ "$language" = "3" ]]; then
        language="english"
    elif [[ "$language" = "4" ]]; then
        language="finnish"
    elif [[ "$language" = "5" ]]; then
        language="french"
    elif [[ "$language" = "6" ]]; then
        language="german"
    elif [[ "$language" = "7" ]]; then
        language="italian"
    elif [[ "$language" = "8" ]]; then
        language="norwegian"
    elif [[ "$language" = "9" ]]; then
        language="polish"
    elif [[ "$language" = "10" ]]; then
        language="portuguese"
    elif [[ "$language" = "11" ]]; then
        language="spanish"
    elif [[ "$language" = "12" ]]; then
        language="swedish"
    fi
    #####################################
 
    if [[ "$fullscreen" = "1" ]]; then
        cmd1="-f"
    else
        cmd1="-w"
    fi
    
    if [[ "$intro" = "1" ]]; then
        cmd2="-intro:off"
    fi
    
    if [[ "$priority" = "1" ]]; then
        priority="Low"
    elif [[ "$priority" = "2" ]]; then
        priority="Normal"
    else
        priority="High"
    fi
    
    flag="$cmd1 -CustomResolution:enabled -r"$width"x"$height"x32 $cmd2 -CPUCount:"$selected_cores" -CPUPriority:"$priority" -l:$language"
    #/usr/libexec/PlistBuddy -c "Set Program\ Flags $flag" "$plist"
    
    #game_exe="/GOG Games/SimCity 4 Deluxe Edition/Apps/SimCity 4.exe"
    
    if [[ "$autosave" = "0" ]]; then
        echo "start \"\" \"C:\\GOG Games\\SimCity 4 Deluxe Edition\\Apps\\SimCity 4.exe\" $flag" > "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/start.bat"
    else
        echo "cd \"C:\\GOG Games\\SimCity 4 Deluxe Edition\"" > "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/start.bat"
        echo "start \"\" \"Apps\\SimCity 4.exe\" $flag" >> "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/start.bat"
        echo "start \"\" autosave $saveinterval" >> "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/start.bat"
    fi
    
    game_exe="/GOG Games/SimCity 4 Deluxe Edition/start.bat"
    /usr/libexec/PlistBuddy -c "Set Program\ Name\ and\ Path $game_exe" "$plist"
    
    #/usr/libexec/PlistBuddy -c "Set Program\ Name\ and\ Path $game_exe" "$plist"
    
    if [[ "$retina" = "1" ]]; then
        sed -ib 's/.*RetinaMode.*/"RetinaMode"="Y"/g' "Contents/Resources/user.reg"
    else
        sed -ib 's/.*RetinaMode.*/"RetinaMode"="N"/g' "Contents/Resources/user.reg"
    fi
    
}

$1


