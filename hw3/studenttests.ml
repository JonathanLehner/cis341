open Assert
open X86
open Ll
open Backend

(* COPIED FROM gradedtests.ml *)

let exec_e2e_ast ll_ast args extra_files =
  let output_path = !Platform.output_path in
  let dot_s_file = Platform.gen_name output_path "test" ".s" in
  let exec_file = Platform.gen_name output_path "exec" "" in
  let asm_ast = Backend.compile_prog ll_ast in
  let asm_str = X86.string_of_prog asm_ast in
  let _ = Driver.write_file dot_s_file asm_str in
  let _ = Platform.link (dot_s_file::extra_files) exec_file in
  let result = Driver.run_executable args exec_file in
  let _ = Platform.sh (Printf.sprintf "rm -f %s %s" dot_s_file exec_file) Platform.ignore_error in
  let _ = Platform.verb @@ Printf.sprintf "** Executable exited with: %d\n" result in
  Int64.of_int result
  

let exec_e2e_file path args =
  let ast = Driver.parse_file path in
  exec_e2e_ast ast args []

let io_test path args =
  let ll_ast = Driver.parse_file path in
  let output_path = !Platform.output_path in
  let dot_s_file = Platform.gen_name output_path "test" ".s" in
  let exec_file = Platform.gen_name output_path "exec" "" in
  let tmp_file = Platform.gen_name output_path "tmp" ".txt" in  
  let asm_ast = Backend.compile_prog ll_ast in
  let asm_str = X86.string_of_prog asm_ast in
  let _ = Driver.write_file dot_s_file asm_str in
  let _ = Platform.link (dot_s_file::["cinterop.c"]) exec_file in
  let args = String.concat " " args in
  let result = Driver.run_program args exec_file tmp_file in
  let _ = Platform.sh (Printf.sprintf "rm -f %s %s %s" dot_s_file exec_file tmp_file) Platform.ignore_error in
  let _ = Platform.verb @@ Printf.sprintf "** Executable output:\n%s\n" result in
  result

let c_link_test c_files path args =
  let ll_ast = Driver.parse_file path in
  let output_path = !Platform.output_path in
  let dot_s_file = Platform.gen_name output_path "test" ".s" in
  let exec_file = Platform.gen_name output_path "exec" "" in
  let asm_ast = Backend.compile_prog ll_ast in
  let asm_str = X86.string_of_prog asm_ast in
  let _ = Driver.write_file dot_s_file asm_str in
  let _ = Platform.link (dot_s_file::c_files) exec_file in
  let args = String.concat " " args in
  let result = Driver.run_executable args exec_file in
  let _ = Platform.sh (Printf.sprintf "rm -f %s %s" dot_s_file exec_file) Platform.ignore_error in
    Int64.of_int result

let executed tests =
  List.map (fun (fn, ans) ->
      fn, assert_eqf (fun () -> exec_e2e_file fn "") ans)
    tests

let executed_io tests =
  List.map (fun (fn, args, ans) ->
      (fn ^ ":" ^ (String.concat " " args)), assert_eqf (fun () -> io_test fn args) ans)
    tests

let executed_c_link tests =
  List.map (fun (c_file, fn, args, ans) ->
      (fn ^ ":" ^ (String.concat " " args)), assert_eqf (fun () -> c_link_test c_file fn args) ans)
    tests

(* STUDENT TESTS FROM PIAZZA *)

(* johnhew *)

let ackermann_io_tests = 
  [ "llprograms/ackermann1_2.ll", [], "4"
  ; "llprograms/ackermann2_4.ll", [], "11"
  ; "llprograms/ackermann3_3.ll", [], "61"
  ; "llprograms/ackermann3_4.ll", [], "125"
  (* this test case brought all *complete* student solutions into infinite loops *)
  (* ; "llprograms/ackermann4_1.ll", [], "65533" *)
  ]

(* whartonv *)

(* lists of numbers for quickselect tests *)
let map_to_string = List.map string_of_int
let through_ten = map_to_string [0;1;2;3;4;5;6;7;8;9;10]
let through_ten_rev = map_to_string [10;9;8;7;6;5;4;3;2;1;0]

let list_through_ints (i:int) : int list =
  let rec loop i =
    if i < 0 then [] else i::loop (i - 1)
  in loop i

let shuffle d =
  let nd = List.map (fun c -> (Random.bits (), c)) d in
  let sond = List.sort compare nd in
    List.map snd sond

let through_503 = shuffle (list_through_ints 503) |> map_to_string
let through_201 = shuffle (list_through_ints 201) |> map_to_string

let quickselect_tests =
  [ ["cinterop.c"], "llprograms/quickselect.ll", map_to_string [0; 0; 1; 2; 3; 4], 0L
  ; ["cinterop.c"], "llprograms/quickselect.ll", map_to_string [3; 0; 1; 2; 3; 4], 3L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "5"::through_ten, 5L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "0"::through_ten, 0L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "10"::through_ten, 10L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "5"::through_ten_rev, 5L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "0"::through_ten_rev, 0L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "10"::through_ten_rev, 10L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "200"::through_503, 200L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "0"::through_503, 0L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "2"::through_503, 2L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "102"::through_503, 102L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "0"::through_201, 0L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "201"::through_201, 201L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "100"::through_201, 100L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "172"::through_201, 172L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "120"::through_201, 120L
  ; ["cinterop.c"], "llprograms/quickselect.ll", "78"::through_201, 78L
  ]

(* keweiqu *)

let gcd_tests =
  [ "llprograms/gcd1071_462.ll", 21L
  ; "llprograms/gcd4_2.ll", 2L
  ]

(* ssumit *)

let selection_sort_tests = 
  [ "llprograms/selectionsort.ll", 4L
  ; "llprograms/selectionsort1.ll", 15L
  ; "llprograms/selectionsort2.ll", 15L
  ; "llprograms/selectionsort3.ll", 1L
  ; "llprograms/selectionsort4.ll", 0L
  ]

(* minski *)

let sqrt_tests =
  [ "llprograms/sqrt1.ll", 10L
  ; "llprograms/sqrt2.ll", 3L
  ; "llprograms/sqrt3.ll", 0L
  ; "llprograms/sqrt4.ll", 35L
  ; "llprograms/sqrt5.ll", 210L
  ]

(* plou *)

let pr_tests =
  [ "llprograms/pollards_rho_3.ll", 0L
  ; "llprograms/pollards_rho_10.ll", 2L
  ; "llprograms/pollards_rho_143.ll", 11L
  ; "llprograms/pollards_rho_8051.ll", 97L
  ; "llprograms/pollards_rho_10403.ll", 101L
  ]

(* kyim *)

let collatz_tests = 
  [ "llprograms/collatz27.ll", 112L
  ; "llprograms/collatz100.ll", 26L
  ]

(* hirshb *)

let knapsack_tests = 
  [ "llprograms/knapsack.ll", 10L
  ; "llprograms/knapsack2.ll", 90L
  ; "llprograms/knapsack3.ll", 99L
  ]

(* burowski *)

let find_max_tests =
  [ "llprograms/find_max_recursive.ll", 122L
  ; "llprograms/find_max_recursive1.ll", 252L (* 252 = unsiged -4. For some reason o'caml treats the result as unsigned int *)
  ; "llprograms/find_max_recursive2.ll", 0L 
  ; "llprograms/find_max_recursive3.ll", 12L
]

(* keviwang *)

(* failed with instructors' solution *)

(*

let fibonacci_tests = 
  [ "llprograms/fibonacci_7.ll", [], "13"
  ; "llprograms/fibonacci_10.ll", [], "55"
  ; "llprograms/fibonacci_25.ll", [], "75025"
  ; "llprograms/fibonacci_15.ll", [], "610"
  ; "llprograms/fibonacci_30.ll", [], "832040"
  ]

*)

(* davidcao *)

let issat_tests =
  [ "llprograms/issat.ll", 1L
  ; "llprograms/notsat.ll", 0L
  ]

(* sukyle *)

let binary_search_tests = 
  [ "llprograms/binary_search0.ll", 0L
  ; "llprograms/binary_search5.ll", 5L
  ; "llprograms/binary_searchneg5.ll", 255L
  ]

(* olekg *)

(* istrinum1 and istrinum2 failed with instructors' solution *)

let tri_tests =
  [ (* "llprograms/istrinum1.ll", 1L
  ; "llprograms/istrinum2.ll", 1L
  ; *) "llprograms/istrinum3.ll", 0L
  ; "llprograms/istrinum4.ll", 0L
  ]

let tests =
  executed ( gcd_tests
           @ selection_sort_tests
           @ sqrt_tests
           @ pr_tests
           @ collatz_tests
           @ knapsack_tests
           @ find_max_tests
           @ issat_tests
           @ binary_search_tests
           @ tri_tests
           )
  @ executed_io ( ackermann_io_tests
                (* @ fibonacci_tests *)
                )
  @ executed_c_link quickselect_tests