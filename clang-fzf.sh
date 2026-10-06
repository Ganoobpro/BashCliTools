#!/usr/bin/env bash

# Kiểm tra file đầu vào
if [ -z "$1" ]; then
  echo "Sử dụng: $0 <file.c|file.cpp>"
  exit 1
fi

SOURCE_FILE="$1"
OUTPUT_FILE="${SOURCE_FILE%.*}"

# Xác định trình biên dịch dựa trên phần mở rộng file
if [[ "$SOURCE_FILE" == *.cpp ]] || [[ "$SOURCE_FILE" == *.cc ]]; then
  COMPILER="clang++"
  VERSION=$(
    cat <<'EOF'
-std=c++23	Chuẩn C++23 (ISO/IEC 14882:2023)	C++
-std=c++20	Chuẩn C++20 (ISO/IEC 14882:2020)	C++
-std=c++17	Chuẩn C++17 (ISO/IEC 14882:2017)	C++
EOF
  )

else
  COMPILER="clang"
  VERSION=$(
    cat <<'EOF'
-std=c11	Chuẩn C11 (ISO/IEC 9899:2011)	C
-std=c17	Chuẩn C17 (ISO/IEC 9899:2018)	C
EOF
  )
fi

# Danh sách cờ: Flag | Mô tả | Chuẩn C/C++ áp dụng
# Phân cách bằng dấu TAB (\t)
FLAGS_DATA=$(
  cat <<'EOF'
-Wall	Bật hầu hết các cảnh báo cơ bản	C/C++
-Wextra	Bật thêm các cảnh báo nâng cao	C/C++
-Werror	Coai tất cả cảnh báo (warnings) là lỗi	C/C++
-O0	Không tối ưu hóa (dễ debug)	C/C++
-O2	Tối ưu hóa cân bằng giữa tốc độ và dung lượng	C/C++
-O3	Tối ưu hóa tối đa tốc độ thực thi	C/C++
-Os	Tối ưu hóa kích thước file thực thi	C/C++
-g	Thêm thông tin debug (dùng cho lldb/gdb)	C/C++
-fsanitize=address	Kiểm tra lỗi bộ nhớ (AddressSanitizer / ASan)	C/C++
-fsanitize=undefined	Kiểm tra lỗi Undefined Behavior (UBSan)	C/C++
EOF
)

# Chạy fzf để chọn flag:
# -m: Cho phép chọn nhiều cờ bằng phím Tab
# --delimiter '\t': Cắt cột theo dấu TAB
# --with-nth 1,2,3: Hiển thị Flag, Mô tả và Chuẩn C/C++
SELECTED_FLAGS=$(echo "$FLAGS_DATA" | column -t -s $'\t' | fzf -m \
  --header="[Tab]: Chọn nhiều | [Shift+Tab]: Bỏ chọn | [Enter]: Xác nhận" \
  --prompt="Chọn Clang Flags > " \
  --preview-window=bottom:30% | awk '{print $1}' | tr '\n' ' ')

SELECTED_VERSION=$(echo "$VERSION" | column -t -s $'\t' | fzf \
  --header="[Enter]: Xác nhận" \
  --prompt="Chọn Clang Version > " \
  --preview-window=bottom:30% | awk '{print $1}' | tr '\n' ' ')

# In lệnh sẽ thực thi
CMD="$COMPILER $SELECTED_VERSION $SELECTED_FLAGS $SOURCE_FILE -o $OUTPUT_FILE"
echo -e "\n\031=> Đang chạy lệnh:\033[0m $CMD\n"

# Thực thi biên dịch và chạy file
eval $CMD && ./"$OUTPUT_FILE"
