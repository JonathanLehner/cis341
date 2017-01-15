module X86 where

import Data.List   (intercalate)
import Data.Int    (Int64)
import Text.Printf (printf)

{- X86lite language representation. -}

{- assembler syntax --------------------------------------------------------- -}

{- Labels for code blocks and global data. -}
type Lbl = String

type Quad = Int64

{- Immediate operands -}
data Imm = Lit Quad | Lbl Lbl

{- Registers:
    instruction pointer: rip
    arguments: rdi, rsi, rdx, rcx, r09, r08
    callee-save: rbx, rbp, r12-r15 
-}
data Reg = Rip
         | Rax | Rbx | Rcx | Rdx | Rsi | Rdi | Rbp | Rsp
         | R08 | R09 | R10 | R11 | R12 | R13 | R14 | R15

data Operand = Imm  Imm       {- immediate -}
             | Reg  Reg       {- register -}
             | Ind1 Imm       {- indirect: displacement -}
             | Ind2 Reg       {- indirect: (%reg) -}
             | Ind3 Imm Reg   {- indirect: displacement(%reg) -}

{- Condition Codes -}
data Cnd = Eq | Neq | Gt | Ge | Lt | Le

data Opcode = Movq | Pushq | Popq
            | Leaq
            | Incq | Decq | Negq | Notq
            | Addq | Subq | Imulq | Xorq | Orq | Andq
            | Shlq | Sarq | Shrq
            | Jmp | J Cnd
            | Cmpq  | Set Cnd
            | Callq | Retq

{- An instruction is an opcode plus its operands.
   Note that arity and other constraints about the operands 
   are not checked. -}
data Ins = Ins Opcode [Operand]

data Data = Asciz String
          | Quad Imm

data Asm = AText [Ins]    {- code -}
         | AData [Data]   {- data -}

{- labeled blocks of data or code -}
data Elem = Elem {
  lbl    :: Lbl,
  global :: Bool,
  asm    :: Asm }

type Prog = [Elem]

{- Provide some syntactic sugar for writing x86 code in OCaml files. -}
{-
module Asm = struct
  let (~$) i = Imm (Lit (Int64.of_int i))      {- int64 constants -}
  let (~$$) l = Imm (Lbl l)                    {- label constants -}
  let (~%) r = Reg r                           {- registers -}
-}

{- helper functions for building blocks of data or code -}
ddata l ds = Elem l True  (AData ds)
text  l is = Elem l False (AText is)
gtext l is = Elem l True  (AText is)

{- pretty printing ----------------------------------------------------------- -}

ppReg :: Reg -> String
ppReg reg = case reg of
  Rip -> "%rip"
  Rax -> "%rax" ; Rbx -> "%rbx" ; Rcx -> "%rcx" ; Rdx -> "%rdx"
  Rsi -> "%rsi" ; Rdi -> "%rdi" ; Rbp -> "%rbp" ; Rsp -> "%rsp"
  R08 -> "%r8"  ; R09 -> "%r9"  ; R10 -> "%r10" ; R11 -> "%r11"
  R12 -> "%r12" ; R13 -> "%r13" ; R14 -> "%r14" ; R15 -> "%r15"

ppLbl :: Lbl -> String
ppLbl = id

ppImm :: Imm -> String
ppImm (Lit i)   = show i
ppImm (Lbl l) = ppLbl l

ppOperand :: Operand -> String
ppOperand op = case op of
  Imm i    -> "$" ++ ppImm i
  Reg r    -> ppReg r
  Ind1 i   -> ppImm i
  Ind2 r   -> "(" ++ ppReg r ++ ")"
  Ind3 i r -> ppImm i ++ "(" ++ ppReg r ++ ")"

ppJmpOperand :: Operand -> String
ppJmpOperand op = case op of
  Imm i    -> ppImm i
  Reg r    -> "*" ++ ppReg r
  Ind1 i   -> "*" ++ ppImm i
  Ind2 r   -> "*" ++ "(" ++ ppReg r ++ ")"
  Ind3 i r -> "*" ++ ppImm i ++ "(" ++ ppReg r ++ ")"

ppCnd :: Cnd -> String
ppCnd c = case c of
  Eq -> "e"  ; Neq -> "ne" ; Gt -> "g"
  Ge -> "ge" ; Lt -> "l"   ; Le -> "le"

ppOpcode :: Opcode -> String
ppOpcode op = case op of
  Movq  -> "movq" ; Pushq -> "pushq" ; Popq -> "popq"
  Leaq  -> "leaq"
  Incq  -> "incq" ; Decq -> "decq" ; Negq -> "negq" ; Notq -> "notq"
  Addq  -> "addq" ; Subq -> "subq" ; Imulq -> "imulq"
  Xorq  -> "xorq" ; Orq -> "orq"  ; Andq -> "andq"
  Shlq  -> "shlq" ; Sarq -> "sarq" ; Shrq -> "shrq"
  Jmp   -> "jmp"  ; J c -> "j" ++ ppCnd c 
  Cmpq  -> "cmpq" ; Set c -> "set" ++ ppCnd c
  Callq -> "callq" ; Retq -> "retq"

mapConcat :: String -> (a -> String) -> [a] -> String
mapConcat s f l = intercalate s (map f l)

ppShift :: Ins -> String
ppShift (Ins op args) = case args of
  [Imm i, _]     -> "\t" ++ ppOpcode op ++ "\t" ++ mapConcat ", " ppOperand args
  [Reg Rcx, dst] ->  printf "\t%s\t%%cl, %s" (ppOpcode op) (ppOperand dst)
  args           -> error (printf "shift instruction has invalid operands: %s\n" 
                           (mapConcat ", " ppOperand args))

ppIns :: Ins -> String
ppIns o@(Ins op args) = case op of
  Shlq -> ppShift o
  Sarq -> ppShift o
  Shrq -> ppShift o
  _    ->
    let f = case op of
              J _   -> ppJmpOperand
              Jmp   -> ppJmpOperand
              Callq -> ppJmpOperand
              _     -> ppOperand
    in  "\t" ++ ppOpcode op ++ "\t" ++ mapConcat ", " f args

ppData :: Data -> String
ppData d = case d of
  Asciz s -> "\t.asciz\t" ++ "\"" ++ s ++ "\""
  Quad i  -> "\t.quad\t" ++ ppImm i

ppAsm :: Asm -> String
ppAsm a = case a of
  AText is -> "\t.text\n" ++ mapConcat "\n" ppIns is
  AData ds -> "\t.data\n" ++ mapConcat "\n" ppData ds

ppElem :: Elem -> String
ppElem (Elem lbl global asm) =
  let (sec, body) = case asm of
                      AText is -> ("\t.text\n", mapConcat "\n" ppIns is)
                      AData ds -> ("\t.data\n", mapConcat "\n" ppData ds)
  in let glb = if global then "\t.globl\t" ++ ppLbl lbl ++ "\n" else "" 
     in sec ++ glb ++ ppLbl lbl ++ ":\n" ++ body

ppProg :: Prog -> String
ppProg p = mapConcat "\n" ppElem p
