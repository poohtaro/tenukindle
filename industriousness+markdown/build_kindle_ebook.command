#!/bin/sh
set -eu
umask 0022
IFS=$(printf ' \t\n_') && IFS=${IFS%_}
export IFS LC_ALL=C LANG=C

XHTML_HEAD='<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="ja" lang="ja">
<head>
<meta http-equiv="Content-Type"
content="text/html; charset=UTF-8" />
<title>本のタイトル</title>
<meta name="author" content="著者名" />
<link rel="stylesheet" href="content.css" type="text/css" />
</head>
<body>
'

XHTML_TAIL='</body></html>
'

NORMALIZED_PAHT_MYSELF="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$NORMALIZED_PAHT_MYSELF"
mkdir -p source

# HTML原稿 (manuscripts) を、
# KDPアップロード用原稿 (source) に加工するスクリプトを、
# 必要に応じて追加する。

printf "%s" "$XHTML_HEAD" >./source/head.tmp

{
    cat ./manuscripts/front-matter-crust.html \
        ./manuscripts/start.md \
        ./manuscripts/chapter-crust.html \
        ./manuscripts/chapter1.md \
        ./manuscripts/chapter-crust.html \
        ./manuscripts/chapter2.md \
        ./manuscripts/column-crust-begin.html \
        ./manuscripts/column1.md \
        ./manuscripts/column-crust-end.html \
        ./manuscripts/chapter-crust.html \
        ./manuscripts/chapter3.md \
        ./manuscripts/endnote-crust.html | pandoc --wrap=preserve -t html4
    # 後注を生成するためpandocの呼び出しを2回に分ける。
    cat ./manuscripts/appendix-crust.html \
        ./manuscripts/appendix.md \
        ./manuscripts/back-matter-crust.html \
        ./manuscripts/back-matter.md \
        ./manuscripts/colophon-crust.html | pandoc --wrap=preserve -t html4
} >./source/body.tmp

{
    cat ./manuscripts/colophon.html
    printf "%s" "$XHTML_TAIL"
} >./source/tail.tmp

cat ./source/head.tmp ./source/body.tmp ./source/tail.tmp >./source/content.html

sed -i.bak -e 's/<li \(id="fn.*"\)><p>\(.*\)\(<a href="#fnref.*\)>.*<\/a><\/p><\/li>/<li><p \1>\3\>^ \<\/a\>\2<\/p><\/li>/' ./source/content.html

cp ./manuscripts/frontmatter.html ./source
cp ./manuscripts/nav.html ./source

cp ./manuscripts/*.gif ./source && true
cp ./manuscripts/*.bmp ./source && true
cp ./manuscripts/*.jpg ./source && true
cp ./manuscripts/*.jpeg ./source && true
cp ./manuscripts/*.png ./source && true
cp ./manuscripts/*.svg ./source && true
cp ./manuscripts/*.css ./source && true
cp ./manuscripts/*.opf ./source && true

printf '\n%s\n\n' '----- validate source html'
tidy -utf8 -xml ./source/*.html >/dev/null

rm ./source/*.bak ./source/*.tmp* && true
zip -r ./source.zip ./source
