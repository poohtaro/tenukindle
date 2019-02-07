#!/bin/sh
set -eu
umask 0022
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
PAHT='/usr/local/bin:/usr/bin:/bin'
export IFS LC_ALL=C LANG=C PATH

PATH_MYSELF=$(dirname "$0")
NORMALIZED_PAHT_MYSELF=$(cd ${PATH_MYSELF}; pwd)

cd "$NORMALIZED_PAHT_MYSELF"
mkdir -p source

# HTML原稿 (manuscripts) を、
# KDPアップロード用原稿 (source) に加工するスクリプトを、
# 必要に応じて追加する。

cp ./manuscripts/*.html ./source && true

cp ./manuscripts/*.gif ./source && true
cp ./manuscripts/*.bmp ./source && true
cp ./manuscripts/*.jpg ./source && true
cp ./manuscripts/*.jpeg ./source && true
cp ./manuscripts/*.png ./source && true
cp ./manuscripts/*.svg ./source && true
cp ./manuscripts/*.css ./source && true
cp ./manuscripts/*.opf ./source && true

printf '\n%s\n\n' '----- validate source html'
tidy -utf8 -xml ./source/*.html > /dev/null

rm ./source/*.bak ./source/*.tmp* && true
zip -r ./source.zip ./source
