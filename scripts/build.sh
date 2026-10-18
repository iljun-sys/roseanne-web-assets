#!/bin/zsh
# 드롭박스 원본 PNG → 홈페이지용 WebP (크기 맞춤 · 1x/2x)
# 사용: scripts/build.sh   (sources.csv 전부 다시 만듦)
# 캐릭터(char): 높이 360(1x) · 720(2x) / 장면(scene): 폭 640(1x) · 1280(2x)
# 원본이 2x보다 작으면 키우지 않고 원본 크기로 둔다
set -e
cd "${0:A:h}/.."
SRC="/Volumes/DataSSD/BCD Dropbox/로즈앤 디자인/08_콘텐츠 소스/02_일러스트/roseanne-assets"
OUT=img/char
mkdir -p $OUT
tail -n +2 sources.csv | while IFS=, read -r name src kind; do
  in="$SRC/$src"
  [[ -f "$in" ]] || { echo "없음: $in"; exit 1; }
  if [[ $kind == char ]]; then key=pixelHeight; one=360; else key=pixelWidth; one=640; fi
  orig=$(sips -g $key "$in" | awk '/pixel/{print $2}')
  two=$(( one*2 < orig ? one*2 : orig ))
  for tag s in 1x $one 2x $two; do
    if [[ $kind == char ]]; then r=(0 $s); else r=($s 0); fi
    cwebp -quiet -q 82 -alpha_q 90 -m 6 -sharp_yuv -resize $r "$in" -o "$OUT/$name-$tag.webp"
  done
done
ls -l $OUT | awk 'NR>1{t+=$5} END{print "합계", t, "bytes"}'
