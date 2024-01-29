#!/bin/bash

# Number of a course (playlist)
COURSE_NUM=84A56BC7F4A1F852

# Assuming 2 playlists
wget 'http://www.youtube.com/view_play_list?p=' -O- | \
    grep -oEe '/watch\?v=[a-zA-Z0-9_-]*\&feature=PlayList\&p=''&index=[0-9]*' |\
    xargs -I'{}' echo 'http://www.youtube.com/''{}' | sort
    
wget 'http://www.youtube.com/view_play_list?p=''&page=2' -O- | \
    grep -oEe '/watch\?v=[a-zA-Z0-9_-]*\&feature=PlayList\&p=''&index=[0-9]*' |\
    xargs -I'{}' echo 'http://www.youtube.com/''{}' | sort 

