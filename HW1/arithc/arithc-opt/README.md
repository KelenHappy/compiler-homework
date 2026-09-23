# OPQ — Optional Question：把答案放在 %rax，不要一直丟到堆疊

> Compiler HW1 / Part 2 附加題報告
> 對應程式碼：`arithc/arithc-opt/compile.ml`（本 README 所在目錄）
> 對照組（原版）：`arithc/arithc/compile.ml`
>
> **以下所有指令，都以本 README 所在的 `arithc-opt/` 目錄為工作目錄。**

---

## 目錄

| 節 | 內容 | 報告用途 |
|---|---|---|
| [0](#0-一句話講完) | 一句話講完 | 開場 |
| [1](#1-先講背景編譯器在幹嘛) · [2](#2-堆疊是什麼給完全沒概念的人) | 背景、堆疊是什麼 | 鋪陳 |
| [3](#3-改了什麼逐段對照) | **逐段對照改了什麼** | 主體 |
| [4](#4-實際看產出print-1--2--3) | 實際產出的組語對照 | 主體 |
| [5](#5-省了多少通用公式) | 省了多少（公式＋實測） | 主體 |
| [6](#6-為什麼結果保證一樣正確性) | 為什麼結果保證一樣 | 深度 |
| [7](#7-怎麼跑) | 怎麼跑、怎麼驗證 | 附帶 |
| [8](#8-一頁懶人包報告時講這幾句就夠) | **一頁懶人包** | 上台照唸 |
| [9](#9-這個做法的極限被問到時可以講) | 這個做法的極限 | 加分 |
| [附錄](#附錄完整-diffarithccompileml--arithc-optcompileml) | 完整 diff 全文 | 附件 |

---

## 0. 一句話講完

**原本**：每算一個小東西，就把答案「丟到地上（堆疊）」，要用的時候再彎腰撿起來。
**現在**：答案先「拿在手上（`%rax` 暫存器）」，只有手要空出來去算別的東西時，才暫時放地上。

題目原文：

> *To use a little less stack space, we can improve this compilation scheme a bit so that the result of `compile_expr` ends up in the `%rax` register rather than on top of the stack. In this way, only the results of left-hand side subexpressions end up on the stack.*

翻成白話：**只有「左邊」那半邊的答案才需要放地上。**

---

## 1. 先講背景：編譯器在幹嘛

我們的迷你語言叫 **Arith**，長這樣：

```
set x = 1 + 2 + 3*4
print (let y = 10 in x + y)
```

編譯器要把它翻成 x86-64 組合語言。翻譯的核心是一個遞迴函式 `comprec`，它走過語法樹（AST）的每一個節點，吐出組語。

```ocaml
type expr =
  | Cst of int                        (* 數字，例如 42 *)
  | Var of string                     (* 變數，例如 x *)
  | Binop of binop * expr * expr      (* e1 + e2、e1 * e2 … *)
  | Letin of string * expr * expr     (* let x = e1 in e2 *)
```

**最關鍵的一件事叫「約定（convention）」**：
遞迴函式必須跟自己約好「我算完之後，答案會放在哪裡」。不然爸爸節點不知道去哪拿小孩算出來的結果。

| | 約定 |
|---|---|
| 原版 | 算完，答案在**堆疊最上面** |
| OPQ 版 | 算完，答案在 **`%rax`** |

整個附加題，就只是**換了這一個約定**而已。其他全部（lexer、parser、AST、`x86_64.ml`）一個字都沒改。

---

## 2. 堆疊是什麼？（給完全沒概念的人）

堆疊（stack）就是一疊盤子，只能從最上面拿、最上面放。

* `pushq %rax` = 把手上的盤子**放到最上面**（要寫記憶體，慢）
* `popq %rax` = 把最上面的盤子**拿到手上**（要讀記憶體，慢）

而 `%rax`、`%rcx` 是 CPU 裡的**暫存器**，就是你的「手」——數量超少（只有十幾隻），但**超快**（不用碰記憶體）。

> 一句話：**暫存器是手，堆疊是地上。能拿在手上就別放地上。**

---

## 3. 改了什麼：逐段對照

### 3-1. 數字 `Cst`

```ocaml
(* 原版 *)  | Cst i -> pushq (imm i)
(* OPQ  *)  | Cst i -> movq (imm i) !%rax
```

```asm
原版：  pushq $42           # 42 丟到地上
OPQ ：  movq  $42, %rax     # 42 拿在手上
```

指令一樣是 1 行，但 OPQ 版**完全沒碰記憶體**。

### 3-2. 變數 `Var`

```ocaml
(* 原版 *)  pushq (ind ~ofs:... rbp)     (* 區域變數 *)
           pushq (lab x)                 (* 全域變數 *)
(* OPQ  *)  movq  (ind ~ofs:... rbp) !%rax
           movq  (lab x) !%rax
```

一樣的道理：**讀出來直接放手上**，不用中轉一次地上。

（`try ... with Not_found` 那段沒變：先找區域變數，找不到才找全域，所以 `let x = ...` 會**蓋掉**外面的同名全域變數，這叫 shadowing。）

### 3-3. 二元運算 `Binop` — 本題的主角 ⭐

```ocaml
(* 原版：兩邊都丟地上 *)
comprec env next e1 ++          (* e1 的值 → 地上 *)
comprec env next e2 ++          (* e2 的值 → 地上 *)
popq rcx ++                     (* 撿起 e2 *)
popq rax ++                     (* 撿起 e1 *)
(match o with ...) ++
pushq !%rax                     (* 結果再丟回地上 *)

(* OPQ：只有 e1 丟地上 *)
comprec env next e1 ++          (* e1 的值 → %rax（手上）*)
pushq !%rax ++                  (* 手要空出來，e1 暫放地上 *)
comprec env next e2 ++          (* e2 的值 → %rax *)
movq !%rax !%rcx ++             (* e2 移到左手 %rcx *)
popq rax ++                     (* e1 撿回右手 %rax *)
(match o with ...)              (* 結果自然留在 %rax，不用再 push *)
```

**為什麼 `e1` 非得放地上不可？**
因為我們只有一隻手（`%rax`）。要去算 `e2`，`e2` 自己也會用 `%rax`，一定會把 `e1` 的值蓋掉。所以只好先寄放。這就是題目說的「只有左半邊會上堆疊」。

**為什麼不乾脆把 `e1` 放在 `%rcx` 就好，連 push 都不用？**
因為 `e2` 如果自己也是一個 `Binop`（例如 `1 + (2*3)`），它裡面**也會用 `%rcx`**，一樣會蓋掉。暫存器就這麼幾隻，遞迴一深就不夠用，所以該寄放還是得寄放。

**為什麼是 `movq %rax, %rcx` + `popq %rax`，而不是直接 `popq %rcx`？**
因為**順序有差**。`subq %rcx, %rax` 算的是 `%rax - %rcx`，也就是 `e1 - e2`。
必須讓 **`%rax` = 左邊、`%rcx` = 右邊**，除法也一樣。如果偷懶寫成 `popq %rcx`，那 `%rcx` 會變成 `e1`、`%rax` 是 `e2`，`3 - 1` 就會算成 `1 - 3`，加法乘法看不出來，**減法除法直接錯**。

**`cqto` 是什麼？**

```ocaml
| Div -> cqto ++ idivq !%rcx
```

`idivq` 很特別，它除的是 **128 位元的 `%rdx:%rax`**，不是只有 `%rax`。
`cqto` 的工作就是把 `%rax` 的正負號「拉長」複製滿整個 `%rdx`（正數填 0，負數填 -1），這樣負數除法才會對。商會留在 `%rax`——**剛好就符合我們的新約定**，什麼都不用再搬。

### 3-4. 區域變數 `Letin`

```ocaml
(* 原版 *)
comprec env next e1 ++
popq rax ++                          (* ← OPQ 版把這行刪了 *)
movq !%rax (ind ~ofs rbp) ++
comprec (StrMap.add x ofs env) (next + 8) e2

(* OPQ *)
comprec env next e1 ++
movq !%rax (ind ~ofs rbp) ++         (* 手上的值直接寫進變數格子 *)
comprec (StrMap.add x ofs env) (next + 8) e2
```

值本來就在手上，**直接寫進去就好，省一行 `popq`**。

（`ofs`、`next`、`frame_size` 那段沒改：`next` 是「下一個空格子」，每個變數佔 8 bytes；`frame_size` 記錄最深要用幾格，開場時一次 `subq` 分配好。）

### 3-5. 指令 `Set` / `Print`

```ocaml
(* Set：存全域變數 *)
原版： code ++ popq rax ++ movq !%rax (lab x)
OPQ ： code ++ movq !%rax (lab x)            (* 省一行 *)

(* Print：印出來 *)
原版： compile_expr e ++ popq rdi ++ call "print_int"
OPQ ： compile_expr e ++ movq !%rax !%rdi ++ call "print_int"
```

`print_int` 依照 x86-64 呼叫慣例，第一個參數要放 `%rdi`，所以從 `%rax` 搬過去。

### 3-6. `compile_program` 完全沒改

開場白（`pushq %rbp` / `movq %rsp, %rbp` / `subq frame_size, %rsp`）、收尾、`print_int` 的本體、`.data` 段全部一模一樣。
堆疊 16-byte 對齊那行也不用動——因為我們在算式中間 push 幾次就會 pop 幾次，**呼叫 `printf` 的當下堆疊一定是平的**。

---

## 4. 實際看產出：`print 1 + 2 * 3`

> 以下是編譯器**實際產出**的組語（`dune exec ./arithc.exe ex.exp`，逐行照貼未經修改）。
> 兩版執行結果都是 `7`。

<table>
<tr><th>原版（值在堆疊）</th><th>OPQ 版（值在 %rax）</th></tr>
<tr><td>

```asm
pushq $1              # 1 → 地上
pushq $2              # 2 → 地上
pushq $3              # 3 → 地上
popq  %rcx            # rcx = 3
popq  %rax            # rax = 2
imulq %rcx, %rax      # rax = 6
pushq %rax            # 6 → 地上
popq  %rcx            # rcx = 6
popq  %rax            # rax = 1
addq  %rcx, %rax      # rax = 7
pushq %rax            # 7 → 地上
popq  %rdi
call  print_int
```

</td><td>

```asm
movq  $1, %rax        # rax = 1
pushq %rax            # 左邊 1 寄放
movq  $2, %rax        # rax = 2
pushq %rax            # 左邊 2 寄放
movq  $3, %rax        # rax = 3
movq  %rax, %rcx      # rcx = 3（右）
popq  %rax            # rax = 2（左）
imulq %rcx, %rax      # rax = 6
movq  %rax, %rcx      # rcx = 6（右）
popq  %rax            # rax = 1（左）
addq  %rcx, %rax      # rax = 7
movq  %rax, %rdi
call  print_int
```

</td></tr>
</table>

| | 原版 | OPQ 版 |
|---|---|---|
| 指令總數 | 13 | 13 |
| `pushq` 次數（寫記憶體） | **5** | **2** |
| `popq` 次數（讀記憶體） | 5 | 2 |
| 堆疊最深幾格 | **3** | **2** |

**誠實說：指令數一樣多。** 省下來的是**記憶體來回的次數**和**堆疊深度**。

---

## 5. 省了多少？通用公式

把一個算式的語法樹數一數：

* **L** = 葉子數（`Cst` 和 `Var` 的總數）
* **B** = `Binop` 節點數
* **T** = `Letin` 節點數
* **D** = 其中除法（`Div`）的個數 —— 每個除法多一行 `cqto`，**兩版都一樣多**

| 項目 | 原版 | OPQ 版 | 差 |
|---|---|---|---|
| `compile_expr` 指令數 | `L + 4B + 2T + D` | `L + 4B + T + D` | 每個 `let` 省 1 |
| `pushq` / `popq` 對數 | `L + B` | `B` | **省掉 L 次記憶體來回** |
| 堆疊最大深度 | `d + 1` | `d` | 少 1 格 |
| `Set` 指令數 | 2 | 1 | 省 1 |

重點那行：**堆疊來回從 `L + B` 降到 `B`——每一個數字、每一個變數，都少跑一趟記憶體。**

拿 `test.exp` 的第一行來套：

```
print (let x = 10 in x) + (let x = 20 in let y = 30 in x+y)
```

L = 6（`10, x, 20, 30, x, y`）、B = 2、T = 3、D = 0

* `compile_expr` 指令數：`6+8+6 = 20` → `6+8+3 = 17`
* 整句（再加上 `Print` 收尾的 2 行）：**22 → 19**
* 堆疊來回：`6+2 = 8 次` → `2 次`（**少 75%**）

### 整支 `test.exp` 的實測數字

| 指標 | 原版 | OPQ 版 | 差 |
|---|---:|---:|---|
| `main` 內指令數 | 115 | **104** | −11 |
| `pushq` 次數 | 41 | **11** | **−73%** |
| `popq` 次數 | 41 | **11** | **−73%** |
| 堆疊最大深度（格） | 3 | **2** | −1 |
| `frame_size` | 16 | 16 | 不變 |
| 執行輸出 | `60 50 0 10 55 60 20 43` | 同左 | **完全一致** |

對得上公式嗎？整支程式 ΣL=30、ΣB=11、ΣT=7、ΣD=3，`Set` 4 次、`Print` 8 次：

* 原版　`30 + 4×11 + 2×7 + 3 + 2×4 + 2×8 = 115` ✅
* OPQ　`30 + 4×11 + 1×7 + 3 + 1×4 + 2×8 = 104` ✅
* 省下的 11 行 = **7 個 `let` + 4 個 `set`**，每個各省一行 `popq` ✅
* `pushq`：原版 `ΣL+ΣB = 30+11 = 41` ✅、OPQ `ΣB = 11` ✅

---

## 6. 為什麼結果保證一樣？（正確性）

用**歸納法**證，只要守住一條不變式（invariant）：

> **`comprec env next e` 產生的程式碼執行完後：
> (1) `e` 的值一定在 `%rax`；
> (2) 堆疊指標 `%rsp` 回到執行前的位置（收支平衡）；
> (3) `%rbp` 以及所有已配置的區域變數格子都沒被動到。**

逐個構造檢查：

* `Cst` / `Var`：一行 `movq` 寫進 `%rax`，沒碰堆疊 ✅
* `Binop`：`e1`（照不變式，值在 `%rax`、堆疊平）→ `pushq`（+1）→ `e2`（照不變式，堆疊平，但會蓋掉 `%rax`、`%rcx`，**這沒關係，因為 `e1` 已經寄放在地上了**）→ `movq`/`popq`（−1）→ 運算。push 和 pop 各一次，平 ✅，結果在 `%rax` ✅
* `Letin`：`e1` → 寫進 `-next-8(%rbp)`（一個專屬格子，`next` 已經 +8，**不會跟 `e2` 的區域變數撞到**）→ `e2`。`e2` 的值在 `%rax` ✅
* `Print` / `Set`：拿 `%rax` 就對了 ✅

因為 `Binop` 的 `e1` 一定先算完、寄放好，才開始算 `e2`，所以**兩邊互相蓋不到對方**。

還有一個常被忽略的點：算式中間的 `pushq` 是壓在 `%rsp` **下面**，而區域變數在 `%rbp` 到 `%rsp` 之間（開場 `subq frame_size, %rsp` 已經保留好了），**兩塊區域完全不重疊**，所以暫存值不會踩到變數。

---

## 7. 怎麼跑

在本 README 所在目錄（`arithc-opt/`）直接執行：

```bash
make            # 編譯器自己 build → 產生 test.s → gcc → 執行 test.out
make clean
```

預期輸出（`test.exp`，跟原版**必須完全一致**）：

```
60
50
0
10
55
60
20
43
```

想直接比對兩版產出的組語：

一樣在 `arithc-opt/` 目錄下執行：

```bash
(cd ../arithc && make) && (make)          # 兩版都 build，各自產生 test.s
diff -u ../arithc/test.s test.s           # 比對兩版組語
grep -c pushq ../arithc/test.s test.s     # 看堆疊操作差多少（實測 43 vs 13）
```

> `grep -c pushq` 是**整份檔案**的計數，裡面含 2 次不屬於表達式求值的 `pushq %rbp`：
> 一次是 `main` 的開場，一次是 `print_int` 的開場（為了維持 16-byte 對齊）。
> 扣掉這 2 次，就是報告裡的 **41 → 11**。

### 本文數據是怎麼驗證的

本報告所有數字皆為**實機執行結果**，環境 OCaml 5.4.0 / dune 3.23.1 / menhir，Fedora 44 x86-64：

| 驗證項目 | 結果 |
|---|---|
| `arithc/` 執行 `make` | 輸出 `60 50 0 10 55 60 20 43`，與 PDF 期望值一致 ✅ |
| `arithc-opt/` 執行 `make` | 輸出**完全相同** ✅ |
| 第 4 節列出的組語 | 與編譯器實際產出**逐行一字不差** ✅ |
| 第 5 節各項統計 | 115/104、41/11、深度 3/2 皆為實測 ✅ |
| `pushq` / `popq` 收支 | 表達式求值結束時堆疊指標回到原位（d = 0），符合第 6 節不變式 ✅ |

> macOS 使用者要改 `x86_64.ml`：`mangle_none` → `mangle_leading_underscore`，`abslab` → `rellab`。
> Fedora 裝工具鏈：`sudo dnf install ocaml ocaml-dune ocaml-menhir`；其他平台用 `opam install dune menhir`。

---

## 8. 一頁懶人包（報告時講這幾句就夠）

1. **附加題只做一件事**：把「算完的值放哪」這個約定，從**堆疊頂端**改成 **`%rax` 暫存器**。
2. **只有二元運算的左半邊**還需要上堆疊，因為算右半邊時會把 `%rax` 蓋掉，得先寄放。
3. **`Cst`、`Var`、`Letin`、`Set` 全部省掉一次 `push`/`pop`**——葉子有幾個，就省幾趟記憶體。
4. **順序不能亂**：`%rax` 放左邊、`%rcx` 放右邊，不然減法和除法會算反。
5. **除法要 `cqto`**，把正負號填滿 `%rdx`，商剛好留在 `%rax`，完美接上新約定。
6. **省在哪**：主要省的是**記憶體流量**（`test.exp` 實測 push/pop 41 → 11，少 73%）和**堆疊深度**（3 → 2）。
   指令數也有降（115 → 104），但那 11 行全來自 `let` 和 `set` 各省一次 `popq`；
   **純算術的部分指令數其實一樣多**（見第 4 節，兩版都是 13 行），省的是對記憶體的存取。
7. **格局**：這正是「暫存器配置（register allocation）」的最初級版本——**能放暫存器就別放記憶體，不夠了才 spill 到堆疊**。差別只在這裡只用了 1 隻暫存器（見第 9 節）。

---

## 9. 這個做法的極限（被問到時可以講）

OPQ 版本把葉子從堆疊解放了，但**它只用了 `%rax` 一隻暫存器**。所以還是有它搞不定的情況。

用真的編譯器實測不同「形狀」的運算式，看堆疊最大深度：

| 運算式 | 形狀 | 原版深度 | OPQ 深度 |
|---|---|---:|---:|
| `1+2+3+4+5` | 左傾（預設左結合） | 2 | **1** |
| `(1+2)+(3+4)` | 平衡 | 3 | **2** |
| `1+(2+(3+(4+5)))` | 右傾 4 層 | 5 | **4** |
| `1+(2+(3+(4+(5+(6+(7+8))))))` | 右傾 8 層 | 8 | **7** |

看得出規律：

* **左傾式子** → OPQ 深度**永遠是 1**，幾乎不碰堆疊，效果最好。
  幸好 Arith 的 `+ - * /` 都是左結合（`parser.mly` 的 `%left`），所以**一般寫法都會落在這個好情況**。
* **右傾式子** → 深度還是跟著巢狀層數**線性成長**。OPQ 只比原版少 1 格，沒有改變成長趨勢。

**為什麼右傾救不了？** 因為 `Binop` 一定是「先算左邊 → 押進堆疊 → 再算右邊」。
右邊越深，被押在下面的東西就要等越久，堆疊自然越高。

### 真正的編譯器會怎麼做（下一步）

1. **先算比較深的那一邊**（Sethi–Ullman / Ershov 編號）
   `+` 和 `*` 有交換律，可以把 `1+(2+3)` 重排成 `(2+3)+1`，右傾直接變左傾。
   `-` 和 `/` 不行（順序有意義），得額外處理。
2. **用更多暫存器**
   x86-64 有 `%rbx`、`%r12`–`%r15` 等被呼叫者保存的暫存器可用。
   前幾層用暫存器，真的不夠了才 spill 到堆疊 —— 這就是**暫存器配置（register allocation）**。

> 一句話總結：**OPQ 是「暫存器配置」最小的一步 —— 從 0 個暫存器變成 1 個。**
> 課程後面講的圖著色（graph coloring）配置，是同一件事做到極致。

---

## 附錄：完整 diff（`arithc/compile.ml` → `arithc-opt/compile.ml`）

本題**所有的改動就是下面這些**，一行不多一行不少。
共 **3 個 hunk、刪 16 行、加 10 行**，全部集中在 `compile_expr` 與 `compile_instr`。
`compile_program` 完全沒動，其餘 11 個檔案（`ast.ml`、`lexer.mll`、`parser.mly`、
`x86_64.ml`、`x86_64.mli`、`compile.mli`、`arithc.ml`、`dune`、`dune-project`、
`Makefile`、`test.exp`）經 `cmp` 逐位元組比對，**全部一模一樣**。

```diff
@@ -1,6 +1,6 @@
 
 
-(* Code production for the language Arith *)
+(* Code production for Arith -- optional question: value in %rax *)
 
 open Format
 open X86_64
@@ -22,40 +22,35 @@
 module StrMap = Map.Make(String)
 
 
-(* Compilation of an expression *)
+(* Compilation of an expression: value left in %rax *)
 let compile_expr =
-  (* Recursive local function to generate the machine code
-     for the abstract syntax tree associated with a value of type
-     Ast.expr ; at the end of the execution of this code, the value must be
-     on top of the stack *)
   let rec comprec env next = function
     | Cst i ->
-        pushq (imm i)
+        movq (imm i) !%rax
     | Var x ->
         (* local shadows global *)
         (try
-           pushq (ind ~ofs:(StrMap.find x env) rbp)
+           movq (ind ~ofs:(StrMap.find x env) rbp) !%rax
          with Not_found ->
            if not (Hashtbl.mem genv x) then raise (VarUndef x);
-           pushq (lab x))
+           movq (lab x) !%rax)
     | Binop (o, e1, e2)->
-        (* e1 then e2 on the stack; %rcx: caller-saved scratch *)
+        (* only e1 reaches the stack; %rcx: caller-saved scratch *)
         comprec env next e1 ++
+        pushq !%rax ++
         comprec env next e2 ++
-        popq rcx ++
+        movq !%rax !%rcx ++
         popq rax ++
         (match o with
            | Add -> addq !%rcx !%rax
            | Sub -> subq !%rcx !%rax
            | Mul -> imulq !%rcx !%rax
            (* sign-extend for idivq *)
-           | Div -> cqto ++ idivq !%rcx) ++
-        pushq !%rax
+           | Div -> cqto ++ idivq !%rcx)
     | Letin (x, e1, e2) ->
         if !frame_size = next then frame_size := 8 + !frame_size;
         let ofs = - next - 8 in
         comprec env next e1 ++
-        popq rax ++
         movq !%rax (ind ~ofs rbp) ++
         comprec (StrMap.add x ofs env) (next + 8) e2
   in
@@ -68,11 +63,10 @@
       let code = compile_expr e in
       Hashtbl.replace genv x ();
       code ++
-      popq rax ++
       movq !%rax (lab x)
   | Print e ->
       compile_expr e ++
-      popq rdi ++
+      movq !%rax !%rdi ++
       call "print_int"
 
 
```

### 怎麼自己重現這份 diff

在本 README 所在目錄（`arithc-opt/`）執行：

```bash
diff -u ../arithc/compile.ml compile.ml
diff -rq -x '_build' -x '*.exe' -x 'test.s' -x 'test.out' -x 'README.md' ../arithc .
```

若你人在 repo 根目錄（`compiler-homework/`）：

```bash
diff -u HW1/arithc/arithc/compile.ml HW1/arithc/arithc-opt/compile.ml
```

若你人在 `HW1/`：

```bash
diff -u arithc/arithc/compile.ml arithc/arithc-opt/compile.ml
```

> 第二條 `diff -rq` 的那串 `-x` 是用來排除建置產物（`_build/`、`arithc.exe`、`test.s`、`test.out`）。
> 沒排除的話，兩邊 `make` 過後會列出一堆 `.cmo` / `.o` 的差異，看起來像改了很多檔，其實沒有。
> 排除後的結果只有一行：**`arithc/compile.ml 與 arithc-opt/compile.ml 不同`** —— 其餘 11 個檔案完全一致。
