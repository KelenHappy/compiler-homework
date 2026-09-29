#!/usr/bin/env bash
cd "$(dirname "$0")"; make -s -C arithc test.out; make -s -C arithc-opt test.out; cat arithc/test.s; cat arithc-opt/test.s; ./arithc/test.out; ./arithc-opt/test.out
