#!/bin/bash

# Dmenu

#SEL=`ls ~/.config/herbstluftwm/layouts/ | dmenu -p "Choose a Layout" -i -l 11`
#herbstclient load "$(cat ~/.config/herbstluftwm/layouts/$SEL)"

# Zenity

LO=`ls -C ~/.config/herbstluftwm/layouts/`

SEL=`zenity --list --title="Choose a Layout" --column="Layouts" $LO`

cat ~/.config/herbstluftwm/layouts/$SEL | bash
