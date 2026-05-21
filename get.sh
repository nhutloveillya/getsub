#!/bin/bash

url_decode() {
  local encoded="${1//+/ }" # Thay thế dấu + thành khoảng trắng nếu có
  # Chuyển đổi %XX thành \xXX để lệnh printf có thể biên dịch ra ký tự thô
  printf '%b\n' "${encoded//%/\\x}"
}

dl() {
  local n="$1"
  local d="$2"
  local p=$(url_decode "$3")
  local pp=$(url_decode "$4")
  if [ -d "$HOME/Downloads/$pp" ]; then
    curl -sSLf -o "$HOME/Downloads/$p" "$d" && echo "Đã tải thành công $n"
  else
    echo "[!] Thư mục chưa tồn tại. Đang tiến hành khởi tạo thư mục..."

    # Sử dụng lệnh mkdir với cờ -p để tự động tạo toàn bộ các thư mục con lồng nhau
    # nếu chúng chưa xuất hiện (ví dụ tạo cả 'my_backups' lẫn 'iso')
    mkdir -p "$HOME/Downloads/$pp"

    # Kiểm tra xem lệnh tạo thư mục có thành công hay không ($? lấy exit code của lệnh vừa chạy)
    if [ $? -eq 0 ]; then
      echo "[THÀNH CÔNG] Đã tạo thành công thư mục: $HOME/Downloads/$pp"
      curl -sSLf -o "$HOME/Downloads/$p" "$d" && echo "Đã tải thành công $n"
    else
      echo "[LỖI CRITICAL] Không thể tạo thư mục. Vui lòng kiểm tra lại quyền ghi (Permission)!"
      exit 1
    fi
  fi
}

#nhap link season anime
read -r -p "Nhập link Season anime trong repo: " link

echo -e "\nBắt đầu tiến hành lấy dữ liệu..."

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

#echo "day la owner: $owner. day la repo: $repo. day la filepath: $filepath"

data=$(curl -s -g -H "Accept: application/json" "https://git.linuxholic.com/api/v1/repos/$owner/$repo/contents/$filepath" | jq)

#printf '%s' "$data"
echo -e "\nĐã lấy dữ liệu thành công.\nBắt đầu tiến hành tải xuống...\n"
#chuyen doi sang object va tai xuong
jq -c '.[]' <<<"$data" | while read -r item; do
  name=$(jq -r '.name' <<<"$item")
  dll=$(jq -r '.download_url' <<<"$item")
  fpath=$(jq -r '.path' <<<"$item")

  dl "$name" "$dll" "$fpath" "$filepath"

done
