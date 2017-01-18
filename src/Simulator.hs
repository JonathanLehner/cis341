module Simulator where

{- X86lite Simulator -}

{- See the documentation in the X86lite specification, available on the 
   course web pages, for a detailed explanation of the instruction
   semantics.
-}

import X86
import Data.Int (Int64)
import Data.Word (Word8)
import Data.Bits (shiftR, shiftL, (.&.), (.|.))
import Data.Char (ord)

{- simulator machine state -------------------------------------------------- -}

mem_bot, mem_top, mem_size, ins_size, exit_addr :: Int64
mem_bot   = 0x400000          {- lowest valid address -}
mem_top   = 0x410000          {- one past the last byte in memory -}
mem_size  = mem_top - mem_bot
ins_size  = 4                 {- assume we have a 4-byte encoding -}
exit_addr = 0xfdead           {- halt when m.regs(%rip) = exit_addr -}

nregs :: Int
nregs = 17                   {- including Rip -}

{- Your simulator should raise this exception if it tries to read from or
   store to an address not within the valid address space. -}
--exception X86lite_segfault

{- The simulator memory maps addresses to symbolic bytes.  Symbolic
   bytes are either actual data indicated by the Byte constructor or
   'symbolic instructions' that take up four bytes for the purposes of
   layout.

   The symbolic bytes abstract away from the details of how
   instructions are represented in memory.  Each instruction takes
   exactly four consecutive bytes, where the first byte InsB0 stores
   the actual instruction, and the next three bytes are InsFrag
   elements, which aren't valid data.

   For example, the two-instruction sequence:
        at&t syntax             ocaml syntax
      movq %rdi, (%rsp)       Movq,  [~%Rdi; Ind2 Rsp]
      decq %rdi               Decq,  [~%Rdi]

   is represented by the following elements of the mem array (starting
   at address 0x400000):

       0x400000 :  InsB0 (Movq,  [~%Rdi; Ind2 Rsp])
       0x400001 :  InsFrag
       0x400002 :  InsFrag
       0x400003 :  InsFrag
       0x400004 :  InsB0 (Decq,  [~%Rdi])
       0x400005 :  InsFrag
       0x400006 :  InsFrag
       0x400007 :  InsFrag
-}
data Sbyte = InsB0 Ins     {- 1st byte of an instruction -}
           | InsFrag       {- 2nd, 3rd, or 4th byte of an instruction -}
           | Byte Word8    {- non-instruction byte -}

{- memory maps addresses to symbolic bytes -}
type Mem = [Sbyte]  -- TODO use array

{- Flags for condition codes -}
data Flags = Flags {
  fo :: Bool,
  fs :: Bool,
  fz :: Bool }

{- Register files -}
type Regs = [Int64] -- TODO: use array

{- Complete machine state -}
data Mach = Mach {
  flags :: Flags,
  regs  :: Regs,
  mem   :: Mem }

{- simulator helper functions ----------------------------------------------- -}

{- The index of a register in the regs array -}
rind :: Reg -> Int
rind r = case r of 
  Rip -> 16
  Rax -> 0  ; Rbx -> 1  ; Rcx -> 2  ; Rdx -> 3
  Rsi -> 4  ; Rdi -> 5  ; Rbp -> 6  ; Rsp -> 7
  R08 -> 8  ; R09 -> 9  ; R10 -> 10 ; R11 -> 11
  R12 -> 12 ; R13 -> 13 ; R14 -> 14 ; R15 -> 15

{- Helper functions for reading/writing sbytes -}

{- Convert an int64 to its sbyte representation -}
int64ToSbytes :: Int64 -> [Sbyte]
int64ToSbytes i = map (\n -> Byte (fromIntegral (shiftR i n) .&. 0xff)) [0,8..56]

{- Convert an sbyte representation to an int64 -}
sBytesToInt64 :: [Sbyte] -> Int64
sBytesToInt64 = foldr f 0
  where f (Byte b) i = (shiftL i 8) .|. (fromIntegral b)
        f _        _ = 0

{- Convert a string to its sbyte representation -}
stringToSbytes :: String -> [Sbyte]
stringToSbytes []     = [Byte 0]
stringToSbytes (c:cs) = Byte (fromIntegral $ ord c) : stringToSbytes cs

{- Serialize an instruction to sbytes -}
insToSbytes :: Ins -> [Sbyte]
insToSbytes ins@(Ins op args) = 
  let err                    = error "insToSbytes: tried to serialize a label!"
      check (Imm (Lbl _))    = err
      check (Ind1 (Lbl _))   = err
      check (Ind3 (Lbl _) _) = err
      check _                = ()
  in seq (map check args) [InsB0 ins, InsFrag, InsFrag, InsFrag]

{- Serialize a data element to sbytes -}
dataToSbytes :: Data -> [Sbyte]
dataToSbytes (Asciz s)      = stringToSbytes s
dataToSbytes (Quad (Lit i)) = int64ToSbytes i
dataToSbytes (Quad (Lbl _)) = error "dataToSbytes: tried to serialize a label!"

{- It might be useful to toggle printing of intermediate states of your 
   simulator. -}
debug_simulator = False

{- Interpret a condition code with respect to the given flags. -}
--let interp_cnd {fo; fs; fz} : cnd -> bool = fun x -> failwith "interp_cnd unimplemented"

{- Maps an X86lite address into Some OCaml array index,
   or None if the address is not within the legal address space. -}
--let map_addr (addr:quad) : int option =
--  failwith "map_addr not implemented"

{- Simulates one step of the machine:
    - fetch the instruction at %rip
    - compute the source and/or destination information from the operands
    - simulate the instruction semantics
    - update the registers and/or memory appropriately
    - set the condition flags
-}
--let step (m:mach) : unit =
--failwith "step unimplemented"

{- Runs the machine until the rip register reaches a designated
   memory address. -}
--let run (m:mach) : int64 = 
--  while m.regs.(rind Rip) <> exit_addr do step m done;
--  m.regs.(rind Rax)

{- assembling and linking --------------------------------------------------- -}

{- A representation of the executable -}
--type exec = { entry    : quad              {- address of the entry point -}
--            ; text_pos : quad              {- starting address of the code -}
--            ; data_pos : quad              {- starting address of the data -}
--            ; text_seg : sbyte list        {- contents of the text segment -}
--            ; data_seg : sbyte list        {- contents of the data segment -}
--            }

{- Assemble should raise this when a label is used but not defined -}
--exception Undefined_sym of lbl

{- Assemble should raise this when a label is defined more than once -}
--exception Redefined_sym of lbl

{- Convert an X86 program into an object file:
   - separate the text and data segments
   - compute the size of each segment
      Note: the size of an Asciz string section is (1 + the string length)

   - resolve the labels to concrete addresses and 'patch' the instructions to 
     replace Lbl values with the corresponding Imm values.

   - the text segment starts at the lowest address
   - the data segment starts after the text segment

  HINT: List.fold_left and List.fold_right are your friends.
 -}
--let assemble (p:prog) : exec =
--failwith "assemble unimplemented"

{- Convert an object file into an executable machine state. 
    - allocate the mem array
    - set up the memory state by writing the symbolic bytes to the 
      appropriate locations 
    - create the inital register state
      - initialize rip to the entry point address
      - initializes rsp to the last word in memory 
      - the other registers are initialized to 0
    - the condition code flags start as 'false'

  Hint: The Array.make, Array.blit, and Array.of_list library functions 
  may be of use.
-}
--let load {entry; text_pos; data_pos; text_seg; data_seg} : mach = 
--failwith "load unimplemented"
