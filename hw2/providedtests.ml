open Assert
open X86
open Simulator
open Gradedtests
open Asm

(* These tests are provided by you -- they will be graded manually *)

(* You should also add additional test cases here to help you   *)
(* debug your program.                                          *)

(* Stein's algorithm; this implementation assumes a > 0 and b > 0.
   See https://courses.cs.washington.edu/courses/cse503/17sp/assignments/hw02-code-analysis.pdf *)
let gcd a b =
  [ text "main"
        [ Movq,  [~$a; ~%Rax]
        ; Movq,  [~$b; ~%Rbx]
        ; Movq,  [~$0; ~%Rcx]     (* d *)
        ]
  ; text "loop1"
         [ Movq,  [~$1; ~%Rsi]
         ; Andq,  [~%Rax; ~%Rsi]  (* 1 if a is odd *)
         ; Movq,  [~$1; ~%Rdi]
         ; Andq,  [~%Rbx; ~%Rdi]  (* 1 if b is odd *)
         ; Orq,   [~%Rsi; ~%Rdi]  (* 1 if a is odd or b is odd *)
         ; Cmpq,  [~$1; ~%Rdi]
         ; J Eq,  [~$$"loop2"]
         ; Sarq,  [~$1; ~%Rax]
         ; Sarq,  [~$1; ~%Rbx]
         ; Incq,  [~%Rcx]
         ; Jmp,   [~$$"loop1"]
         ]
  ; text "loop2"
         [ Cmpq,  [~%Rax; ~%Rbx]
         ; J Eq,  [~$$"exit"]
         ; Movq,  [~$1; ~%Rsi]
         ; Andq,  [~%Rax; ~%Rsi]  (* 1 if a is odd; 0 if even *)
         ; Cmpq,  [~$0; ~%Rsi]
         ; J Eq,  [~$$"a even"]
         ; Movq,  [~$1; ~%Rsi]
         ; Andq,  [~%Rbx; ~%Rsi]  (* 1 if b is odd; 0 if even *)
         ; Cmpq,  [~$0; ~%Rsi]
         ; J Eq,  [~$$"b even"]
         ; Cmpq,  [~%Rbx; ~%Rax]  (* test a ? b *)
         ; J Gt,  [~$$"a > b"]
         ; Jmp,   [~$$"b > a"]
         ]
  ; text "a even"
         [ Sarq,  [~$1; ~%Rax]
         ; Jmp,   [~$$"loop2"]
         ]
  ; text "b even"
         [ Sarq,  [~$1; ~%Rbx]
         ; Jmp,   [~$$"loop2"]
         ]
  ; text "a > b"
         [ Subq,  [~%Rbx; ~%Rax]
         ; Sarq,  [~$1; ~%Rax]
         ; Jmp,   [~$$"loop2"]
         ]
  ; text "b > a"
         [ Subq,  [~%Rax; ~%Rbx]
         ; Sarq,  [~$1; ~%Rbx]
         ; Jmp,   [~$$"loop2"]
         ]
  ; text "exit"
         [ Movq,  [~$1; ~%Rsi]
         ; Shlq,  [~%Rcx; ~%Rsi]  (* 2^d *)
         ; Imulq, [~%Rsi; ~%Rax]  (* a * 2^d *)
         ; Retq,  [] 
         ]
  ]

let provided_tests : suite = [
  Test ("Student-Provided Big Test for Part III: Score recorded as PartIIITestCase", [
       ]);
 
  Test ("GCD", [
          ("gcd 2 3", program_test (gcd 2 3) 1L);
          ("gcd 1 3", program_test (gcd 1 3) 1L);
          ("gcd 2 1", program_test (gcd 2 1) 1L);
          ("gcd 12 18", program_test (gcd 12 18) 6L);
          ("gcd 20 20", program_test (gcd 20 20) 20L);
       ]);
] 
