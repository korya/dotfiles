aws_load() {
  sed -n '/^aws_[a-z_]* *=/{s/^\([a-z_]*\) *= *\(.*\)$/export \U\1=\E\2/;p}' \
    ${HOME}/.aws/credentials
}
