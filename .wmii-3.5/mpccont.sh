#!/bin/sh
IFS=$'\n'
MUSIC_DIR="/var/lib/mpd/music/"

st=`mpc ls $1 | awk 'BEGIN {FS="\n"; RS=""} END {print ".\n" "..\n" $0}' | eval $WMII_MENU`

# пустая строка? стало быть нажали ESC, надо выходить
if [ -z $st ]; then
	exit
fi

# играть все, что есть в директории
if [ $st = '.' ]; then
	mpc clear
	`mpc ls $1 | mpc add`
	mpc play
	exit
fi

# подняться на один уровень вверх
if [ $st = '..' ]; then
	dir=`dirname $1 | sed s/^\.//`
	exec $HOME/.wmii-3.5/mpccont.sh "$dir"
fi

# показать все имеющиеся директории в выбранной
for name in `ls "$MUSIC_DIR/$st"` ; do
	if [ -d "$MUSIC_DIR/$st/$name" ] ; then
		exec $HOME/.wmii-3.5/mpccont.sh "$st"
	fi
done

# если дошли до этого места, значит выбрали директорию с файлами.
# добавить ее и воспроизвести
mpc clear
mpc add "$st"
mpc play
