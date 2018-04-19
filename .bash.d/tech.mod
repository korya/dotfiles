# vim: set filetype=sh :

get_course_files()
{
    wget -O- "$@" | tr -d '\n' | \
        sed -n '/^http.*pdf$/p;/^http.*ppt$/p;/^http.*doc$/p;/^http.*ps$/p'
# Original:
#     wget -O- "$@" | grep '<a href' | sed 's/\"/\n/g' | \
#         sed -n '/^http.*pdf$/p;/^http.*ppt$/p;/^http.*doc$/p;/^http.*ps$/p'
}

