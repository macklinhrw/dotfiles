#!/bin/bash

# Dmenu

#FI=`dmenu -p "Enter the name of the new layout" `
#herbstclient dump > ~/.config/herbstluftwm/layouts/$FI

# Zenity

LAY=`herbstclient dump`
ENT=`echo "herbstclient load '$LAY'"` 

FI=`zenity --entry --title="Save the current Layout" --text="Enter name of new Layout:" --entry-text "NewLayout"`

echo "$ENT" > ~/.config/herbstluftwm/layouts/$FI 
