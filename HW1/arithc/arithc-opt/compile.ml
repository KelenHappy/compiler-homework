

(* Code production for the language Arith
   -- optional question: the value of an expression is left in %rax
      instead of on top of the stack, so that only the results of
      left-hand side subexpressions ever reach the stack. *)

open Format
open X86_64
open Ast


(* Raise exception when a variable (local or global) is misused *)
exception VarUndef of string

(* Size of the frame, in bytes (each local variable occupies 8 bytes) *)
let frame_size = ref 0

(* Global variables are stored in a hash table *)
let (genv : (string, unit) Hashtbl.t) = Hashtbl.create 17

(* We use an association table whose keys are local variables
   (strings) and whose associated value is the position
   relative to %rbp (in bytes) *)
module StrMap = Map.Make(String)


(* Compilation of an expression: at the end of the generated code the
   value of the expression is in %rax *)
let compile_expr =
  let rec comprec env next = function
    | Cst i ->
        movq (imm i) !%rax
    | Var x ->
        (* a local variable shadows a global one of the same name *)
        (try
           movq (ind ~ofs:(StrMap.find x env) rbp) !%rax
         with Not_found ->
           if not (Hashtbl.mem genv x) then raise (VarUndef x);
           movq (lab x) !%rax)
    | Binop (o, e1, e2)->
        (* only the left operand has to be saved on the stack, while the
           right one is being evaluated; the right one stays in %rax *)
        comprec env next e1 ++
        pushq !%rax ++
        comprec env next e2 ++
        movq !%rax !%rbx ++
        popq rax ++
        (match o with
           | Add -> addq !%rbx !%rax
           | Sub -> subq !%rbx !%rax
           | Mul -> imulq !%rbx !%rax
           (* cqto sign-extends %rax into %rdx:%rax, as idivq requires;
              the quotient is left in %rax *)
           | Div -> cqto ++ idivq !%rbx)
    | Letin (x, e1, e2) ->
        if !frame_size = next then frame_size := 8 + !frame_size;
        let ofs = - next - 8 in
        (* no stack traffic at all here: the value of e1 goes straight
           from %rax to the slot reserved for x *)
        comprec env next e1 ++
        movq !%rax (ind ~ofs rbp) ++
        comprec (StrMap.add x ofs env) (next + 8) e2
  in
  comprec StrMap.empty 0

(* Compilation of an instruction *)
let compile_instr = function
  | Set (x, e) ->
      (* e is compiled first, so that "set x = x + 1" on an undeclared x
         is still reported as an error *)
      let code = compile_expr e in
      Hashtbl.replace genv x ();
      code ++
      movq !%rax (lab x)
  | Print e ->
      compile_expr e ++
      movq !%rax !%rdi ++
      call "print_int"


(* Compilation of the program p and saving the code in the file ofile *)
let compile_program p ofile =
  let code = List.map compile_instr p in
  let code = List.fold_right (++) code nop in
  if !frame_size mod 16 = 8 then frame_size := 8 + !frame_size;
  let p =
    { text =
        globl "main" ++ label "main" ++
        pushq !%rbp ++
        movq !%rsp !%rbp ++
        subq (imm !frame_size) !%rsp ++
        code ++
        movq !%rbp !%rsp ++
        popq rbp ++
        movq (imm 0) !%rax ++
        ret ++
        label "print_int" ++
        pushq !%rbp ++ (* ensure proper alignment *)
        movq !%rdi !%rsi ++
        leaq (lab ".Sprint_int") rdi ++
        movq (imm 0) !%rax ++
        call "printf" ++
        popq rbp ++
        ret;
      data =
        Hashtbl.fold (fun x _ l -> label x ++ dquad [1] ++ l) genv
          (label ".Sprint_int" ++ string "%d\n")
    }
  in
  let f = open_out ofile in
  let fmt = formatter_of_out_channel f in
  X86_64.print_program fmt p;
  (* flush the buffer to ensure everything is written before closing *)
  fprintf fmt "@?";
  close_out f
