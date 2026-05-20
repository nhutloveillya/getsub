#!/bin/bash

#nhap link season anime
read -p "Nhap link Season anime trong repo: " link

#echo "$link"

owner=$(echo "$link" | cut -d'/' -f4)
repo=$(echo "$link" | cut -d'/' -f5)

KEYWORD="/master/"

filepath=$(echo "$link" | awk -v kw="$KEYWORD" '
    idx = match($0, kw) {
        if (idx > 0) {
            # Bắt đầu cắt từ vị trí sau từ khóa
            print substr($0, idx + length(kw))
        } else {
            print "Không tìm thấy từ khóa"
        }
    }
')

echo "day la owner: $owner. day la repo: $repo. day la filepath: $filepath"

data=$(curl -s -g -H "Accept: application/json" "https://git.linuxholic.com/api/v1/repos/$owner/$repo/contents/$filepath" | jq)

printf '%s' "$data"
