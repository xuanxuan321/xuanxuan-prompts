#!/usr/bin/env bash
#
# mp4-to-gif.sh —— 把仓库里所有 .mp4 转成同名 .gif（并生成首帧封面 .poster.jpg），
#                 然后删掉原 mp4。
#
# 用法：
#   ./mp4-to-gif.sh                # 在当前 git 仓库（或当前目录）下递归处理所有 mp4
#   WIDTH=600 FPS=12 ./mp4-to-gif.sh   # 自定义分辨率/帧率
#   KEEP_MP4=1 ./mp4-to-gif.sh     # 只转换、保留原 mp4（不删）
#   MAX_MB=6 ./mp4-to-gif.sh       # GIF 超过这个体积就自动再降档重压
#
# 依赖：ffmpeg（brew install ffmpeg）
#
# 说明：只有 GIF 成功生成（文件非空）后才会删除对应的 mp4；
#      转换失败会保留 mp4 并继续处理下一个。

set -uo pipefail

# ---- 可调参数（都可用环境变量覆盖）----
WIDTH="${WIDTH:-720}"     # 第一档宽度（高度等比）
FPS="${FPS:-15}"          # 第一档帧率
MAX_MB="${MAX_MB:-8}"     # GIF 超过多少 MB 就自动降档重压
KEEP_MP4="${KEEP_MP4:-0}" # 1 = 保留原 mp4

# ---- 检查依赖 ----
if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "❌ 未找到 ffmpeg，请先安装：brew install ffmpeg" >&2
  exit 1
fi

# ---- 定位处理根目录：优先 git 仓库根，否则当前目录 ----
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# ---- 跨平台取文件大小（字节）----
filesize() {
  stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0
}

# ---- 生成 GIF：$1 输入  $2 输出  $3 宽  $4 帧率  $5 是否粗抖动(0/1) ----
make_gif() {
  local in="$1" out="$2" w="$3" fps="$4" dither="$5"
  local use="paletteuse"
  [ "$dither" = "1" ] && use="paletteuse=dither=bayer:bayer_scale=5"
  ffmpeg -y -loglevel error -i "$in" \
    -vf "fps=${fps},scale=${w}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]${use}" \
    "$out"
}

echo "🔍 扫描目录：$ROOT"
echo "   参数：宽=${WIDTH}px 帧率=${FPS}fps 上限=${MAX_MB}MB 保留mp4=${KEEP_MP4}"
echo ""

found=0
converted=0
while IFS= read -r -d '' mp4; do
  found=$((found + 1))
  gif="${mp4%.mp4}.gif"
  rel="${mp4#$ROOT/}"
  echo "▶ $rel"

  # 第一档
  make_gif "$mp4" "$gif" "$WIDTH" "$FPS" 0
  mb=$(( $(filesize "$gif") / 1024 / 1024 ))

  # 超限就降到 600px/12fps + 粗抖动
  if [ "$mb" -gt "$MAX_MB" ]; then
    echo "   ↳ ${mb}MB 偏大，降到 600px/12fps 重压…"
    make_gif "$mp4" "$gif" 600 12 1
    mb=$(( $(filesize "$gif") / 1024 / 1024 ))
  fi
  # 还超限再降到 480px/10fps
  if [ "$mb" -gt "$MAX_MB" ]; then
    echo "   ↳ 仍 ${mb}MB，降到 480px/10fps 再压…"
    make_gif "$mp4" "$gif" 480 10 1
    mb=$(( $(filesize "$gif") / 1024 / 1024 ))
  fi

  # 成功生成才删 mp4
  if [ -s "$gif" ]; then
    converted=$((converted + 1))
    # 首帧封面（轻量 jpg；README 默认显示封面，点击才加载完整 gif）
    poster="${mp4%.mp4}.poster.jpg"
    ffmpeg -y -loglevel error -i "$gif" -frames:v 1 -update 1 -q:v 3 "$poster"
    if [ "$KEEP_MP4" = "1" ]; then
      echo "   ✅ ${gif#$ROOT/} + 封面（${mb}MB，保留原 mp4）"
    else
      rm -f "$mp4"
      echo "   ✅ ${gif#$ROOT/} + 封面（${mb}MB），已删除原 mp4"
    fi
  else
    echo "   ❌ 转换失败，保留原 mp4"
    rm -f "$gif" 2>/dev/null || true
  fi
done < <(find "$ROOT" -type f -name '*.mp4' -not -path '*/.git/*' -print0)

echo ""
if [ "$found" -eq 0 ]; then
  echo "（没找到任何 .mp4）"
else
  echo "🎉 完成：共 $found 个 mp4，成功转换 $converted 个。"
fi
