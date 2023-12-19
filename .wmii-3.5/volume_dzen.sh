#!/bin/bash
# little dzen-thingy to control your volume
# you need amixer (or aumix) and gdbar
# (c) 2007 Tom Rauchenwald and Jochen Schweizer
 
BG='#000'     # dzen backgrounad
FG='#888'     # dzen foreground
W=105         # width of the dzen bar
GW=50         #  width of the volume gauge
GFG='#a8a3f5' # color of the gauge
GH=8          # height of the gauge
GBG='#333'    # color of gauge background
X=1055         # x position
Y=1008         # y position
  
# Caption of the gauge
# in this case it displays the volume icon shipped with dzen
CAPTION="^i(/home/sec/share/images/volume.xbm) "
# Font to use
FN=$WMII_FONT #'-xos4-terminus-*-*-*-*-12-*-*-*-*-*-*-*'
   
# command to increase the volume
CI="amixer -c0 sset PCM 5%+ >/dev/null"
#CI="aumix -v +5"
# command to decrease the volume
CD="amixer -c0 sset PCM 5%- >/dev/null"
#CD="aumix -v -5
    
# command to pipe into gdbar to display the gauge
# should print out 2 space-seperated values, the first is the current
# volume, the second the maximum volume
MAX=`amixer -c0 get PCM | awk '/^  Limits/ { print $5 }'`
#MAX=100
CV="amixer -c0 get PCM | awk '/^  Front Left/ { print \$4 \" \" $MAX }'"
#CV="aumix -q | line | cut -d \" \" -f 3"
	 
while true; do
	echo -n $CAPTION
	eval "$CV" | dzen2-gdbar -h $GH -w $GW -fg $GFG -bg $GBG
	sleep 1;
done #| dzen2 -ta c -tw $W -y $Y -x $X -fg $FG -bg $BG -e "button2=exit;button3=exec:$CI;button1=exec:$CD" -fn $FN

