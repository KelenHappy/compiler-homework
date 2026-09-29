#!/usr/bin/env bash
# OPQ 附加題驗證：建置兩版、比對輸出、統計堆疊操作
# 用法：./opq-demo.sh          （加 --diff 會多印 compile.ml 的差異）
set -euo pipefail
cd "$(dirname "$0")"

B=$'\e[1m'; G=$'\e[32m'; R=$'\e[31m'; C=$'\e[36m'; N=$'\e[0m'
hr() { printf '%s\n' "${C}━━━━━━━━━━ $1 ━━━━━━━━━━${N}"; }

for d in arithc arithc-opt; do
  make -s -C "$d" test.out >/dev/null 2>&1 || { echo "${R}$d 建置失敗${N}"; exit 1; }
done

hr "1. 執行結果（原版 vs OPQ）"
printf "${B}%-10s %-10s${N}\n" "原版" "OPQ"
paste <(./arithc/test.out) <(./arithc-opt/test.out) | awk -F'\t' '{printf "%-10s %-10s\n",$1,$2}'
if diff -q <(./arithc/test.out) <(./arithc-opt/test.out) >/dev/null; then
  echo "${G}✔ 輸出完全一致${N}"
else
  echo "${R}✘ 輸出不同${N}"
fi

hr "2. pushq 分類（main + print_int）"
kind() {
  grep -h 'pushq' "$1" | sed -E 's/^\s+//; s/\s+/ /g' |
  sed -E 's/^pushq \$.*/常數  (pushq $imm)/;
          s/^pushq -?[0-9]+\(%rbp\)/區域變數 (pushq ofs(%rbp))/;
          s/^pushq %rax$/Binop  (pushq %rax)/;
          s/^pushq %rbp$/開場  (pushq %rbp)/;
          s/^pushq [a-z_]+$/全域變數 (pushq label)/' |
  sort | uniq -c | sort -rn
}
echo "${B}[原版]${N}";  kind arithc/test.s
echo "${B}[OPQ]${N}";   kind arithc-opt/test.s

hr "3. 堆疊操作總數"
count() { grep -c "$1" "$2"; }
printf "${B}%-8s %6s %6s${N}\n" "" "原版" "OPQ"
for op in pushq popq; do
  printf "%-8s %6d %6d\n" "$op" "$(count $op arithc/test.s)" "$(count $op arithc-opt/test.s)"
done
echo "（兩版各含 2 次 pushq %rbp 開場，扣掉後為 $(( $(count pushq arithc/test.s)-2 )) → $(( $(count pushq arithc-opt/test.s)-2 ))）"

if [[ "${1:-}" == "--diff" ]]; then
  hr "4. compile.ml 差異"
  diff -u --color=always arithc/compile.ml arithc-opt/compile.ml || true
fi
