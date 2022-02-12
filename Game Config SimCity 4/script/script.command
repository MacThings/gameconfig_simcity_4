#!/bin/bash
#

gamename="zootycoon"

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

cd ../../../../Zoo\ Tycoon.app
ini="Contents/Resources/drive_c/Program Files/Microsoft Games/Zoo Tycoon/zoo.ini"

wrapperpath=$( PWD )
_helpDefaultWrite "WrapperPath" "$wrapperpath"

function _check_for_game()
{

    if [ -d "Contents/Resources/drive_c/Program Files/Microsoft Games/Zoo Tycoon/XPACK2" ]; then
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameInstalled" -bool TRUE
    else
        defaults write "${ScriptHome}/Library/Preferences/gameconfig-$gamename.slsoft.de" "GameInstalled" -bool FALSE
    fi
        

}

function _open_wineskin()
{

    open -a Wineskin.app

}

function _play()
{
    
    cd "$MY_PATH"
    cd ../../../..
    
    if [ ! -d /Volumes/MARINE ]; then
        hdiutil mount "Zoo Tycoon.app/MARINE.iso" >/dev/null 2>&1
    fi
    
    open -a "Zoo Tycoon.app"
    
    #sleep 10

    #if [ -d /Volumes/ZOO_TYCN ]; then
    #    hdiutil eject /Volumes/ZOO_TYCN
    #fi

    #if [ -d /Volumes/MARINE ]; then
    #    hdiutil eject /Volumes/MARINE
    #fi

}

function _save_config()
{

    custom=$( _helpDefaultRead "Custom" )
    width=$( _helpDefaultRead "Width" )
    height=$( _helpDefaultRead "Height" )
    fullscreen=$( _helpDefaultRead "Fullscreen" )
    retina=$( _helpDefaultRead "Retina" )
    coloredmouse=$( _helpDefaultRead "ColoredMouse" )
    
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
    
    if [[ "$coloredmouse" = "1" ]]; then
        sed -ib "s/useAlternateCursors.*/useAlternateCursors=1/g" "$ini"
    else
        sed -ib "s/useAlternateCursors.*/useAlternateCursors=0/g" "$ini"
    fi
}

$1


