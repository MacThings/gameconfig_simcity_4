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

function _check_for_game()
{

    if [ -d "Contents/Resources/drive_c/GOG Games/SimCity 4 Deluxe Edition/Apps" ]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameInstalled" -bool TRUE
    else
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameInstalled" -bool FALSE
    fi
        

}

function _open_wineskin()
{

    open Wineskin.app

}

function _language()
{
    
    open "ChangeLanguage.app"
    
    
}

function _play()
{
    
    open "../SimCity 4.app"
    
    
}

function _save_config()
{

    custom=$( _helpDefaultRead "Custom" )
    width=$( _helpDefaultRead "Width" )
    height=$( _helpDefaultRead "Height" )
    fullscreen=$( _helpDefaultRead "Fullscreen" )
    retina=$( _helpDefaultRead "Retina" )
    
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
    
    if [[ "$fullscreen" = "1" ]]; then
        cmd1="-f"
    else
        cmd1="-w"
    fi
    
    echo "$width" > /private/tmp/yo
    
    flag="$cmd1 -CustomResolution:enabled -r"$width"x"$height"x32"
    
    /usr/libexec/PlistBuddy -c "Set Program\ Flags $flag" "$plist"
    
    exit
    
    sed -ib "s/screenwidth.*/screenwidth=$width/g" "$ini"
    sed -ib "s/screenheight.*/screenheight=$height/g" "$ini"
    
    sed -ib "s/fullscreen.*/fullscreen=1/g" "$ini"
    
    if [[ "$fullscreen" = "1" ]]; then
        sed -ib "s/fullscreen.*/fullscreen=1/g" "$ini"
    else
        sed -ib "s/fullscreen.*/fullscreen=0/g" "$ini"
    fi
    
    if [[ "$retina" = "1" ]]; then
        sed -ib 's/.*RetinaMode.*/"RetinaMode"="Y"/g' "Contents/Resources/user.reg"
    else
        sed -ib 's/.*RetinaMode.*/"RetinaMode"="N"/g' "Contents/Resources/user.reg"
    fi
}

$1


