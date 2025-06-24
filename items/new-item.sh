#!/bin/sh

echo "File name"
read title
cp example-item/example-item.md $title.md
vim $title.md
