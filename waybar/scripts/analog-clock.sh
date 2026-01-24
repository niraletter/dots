#!/usr/bin/env bash
H=$(date +%H)
M=$(date +%M)
S=$(date +%S)
h=${H#0}; [ -z "$h" ] && h=0
m=${M#0}; [ -z "$m" ] && m=0
minute_of_12h=$(( (h % 12) * 60 + m ))
codepoint=$((0xE000 + minute_of_12h))
printf -v esc '\\U%04X' "$codepoint"
glyph=$(printf "$esc")
tooltip="${H}:${M}:${S}"
printf '{"text":"%s","tooltip":"%s"}\n' "$glyph" "$tooltip"
