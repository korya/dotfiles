#!/bin/bash
#
# Dlya podderjki russkogo

WMII9MENU_FONT='-cronyx-helvetica-medium-r-*--14-100-*-*-*-*-koi8-*' # -*-helvetica-medium-r-*-*-14-*-*-*-*-*-koi8-*

NF="$(echo $WMII_NORMCOLORS | cut -d' ' -f1)"
NB="$(echo $WMII_NORMCOLORS | cut -d' ' -f2)"
SF="$(echo $WMII_FOCUSCOLORS | cut -d' ' -f1)"
SB="$(echo $WMII_FOCUSCOLORS | cut -d' ' -f2)"
BR="$(echo $WMII_FOCUSCOLORS | cut -d' ' -f3)"
wmii9menu -font $WMII9MENU_FONT -nf $NF -nb $NB \
    -sf $SF -sb $SB -br $BR $(echo $@ | iconv -f utf8 -t koi8-ru) | \
    iconv -f koi8-ru -t utf8

