#!/bin/zsh
# 드롭박스 원본 PNG → 홈페이지용 WebP (크기 맞춤 · 1x/2x)
# 사용: scripts/build.sh   (sources.csv 전부 다시 만듦)
# 캐릭터(char): 높이 360(1x) · 720(2x) / 장면(scene): 폭 640(1x) · 1280(2x) / 상반신(upper): 폭 800(1x) · 1600(2x)
# 원본이 2x보다 작으면 키우지 않고 원본 크기로 둔다
# 클로즈업 첫 화면용 <name>-hd.webp(여백 자른 원본 → 높이 1300)는 손으로 만든 것 — 이 스크립트가 만들지 않음(2026-10-21 · 13장)
set -e
cd "${0:A:h}/.."
SRC="/Volumes/DataSSD/BCD Dropbox/로즈앤 디자인/08_콘텐츠 소스/02_일러스트/roseanne-assets"
OUT=img/char
mkdir -p $OUT
tail -n +2 sources.csv | while IFS=, read -r name src kind; do
  [[ $kind == upper-crop ]] && continue   # 상반신 잘라 만든 그림(하단 안내 띠용)은 손으로 만든 것 — 다시 만들지 않음
  if [[ $src == /* ]]; then in="$src"; else in="$SRC/$src"; fi   # 절대 경로면 그대로
  [[ -f "$in" ]] || { echo "없음: $in"; exit 1; }
  if [[ $kind == char ]]; then key=pixelHeight; one=360; elif [[ $kind == upper ]]; then key=pixelWidth; one=800; else key=pixelWidth; one=640; fi   # upper = 원장 상반신(크게 쓰는 그림)
  orig=$(sips -g $key "$in" | awk '/pixel/{print $2}')
  two=$(( one*2 < orig ? one*2 : orig ))
  for tag s in 1x $one 2x $two; do
    if [[ $kind == char ]]; then r=(0 $s); else r=($s 0); fi
    cwebp -quiet -q 82 -alpha_q 90 -m 6 -sharp_yuv -resize $r "$in" -o "$OUT/$name-$tag.webp"
  done
done
ls -l $OUT | awk 'NR>1{t+=$5} END{print "합계", t, "bytes"}'
