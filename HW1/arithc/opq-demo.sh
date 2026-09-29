#!/usr/bin/env bash
# set -x：每條指令執行前都會印出來；set -e：任何一步失敗（含 diff 不一致）就立刻停下
set -ex
cd "$(dirname "$0")"
rm -f arithc/test.s arithc/test.out arithc/opq.s arithc/opq.out arithc-opt/test.s arithc-opt/test.out arithc-opt/opq.s arithc-opt/opq.out
make -s -C arithc clean; make -s -C arithc-opt clean
make -s -C arithc test.out; make -s -C arithc-opt test.out
cd arithc; dune exec ./arithc.exe -- ../opq.exp -o opq.s; gcc -g -no-pie opq.s -o opq.out; cd ..
cd arithc-opt; dune exec ./arithc.exe -- ../opq.exp -o opq.s; gcc -g -no-pie opq.s -o opq.out; cd ..
diff <(printf '60\n50\n0\n10\n55\n60\n20\n43\n') <(./arithc-opt/test.out)
diff opq.expected <(./arithc-opt/opq.out)
diff <(./arithc/opq.out) <(./arithc-opt/opq.out)
paste opq.expected <(./arithc/opq.out) <(./arithc-opt/opq.out)
grep 'pushq \$' arithc/opq.s | wc -l; grep 'pushq \$' arithc-opt/opq.s | wc -l
grep pushq arithc-opt/opq.s | sort | uniq -c
