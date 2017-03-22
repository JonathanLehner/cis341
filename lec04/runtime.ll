; ModuleID = 'runtime.c'
source_filename = "runtime.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.12.0"

@.str = private unnamed_addr constant [8 x i8] c"strtoll\00", align 1
@.str.1 = private unnamed_addr constant [29 x i8] c"usage: calculator x1 .. x%d\0A\00", align 1
@.str.2 = private unnamed_addr constant [24 x i8] c"program returned: %lld\0A\00", align 1

; Function Attrs: nounwind ssp uwtable
define i64 @get_int64(i8*) #0 {
  %2 = alloca i8*, align 8
  %3 = alloca i8*, align 8
  %4 = alloca i64, align 8
  store i8* %0, i8** %2, align 8
  %5 = call i32* @__error()
  store i32 0, i32* %5, align 4
  %6 = load i8*, i8** %2, align 8
  %7 = call i64 @strtoll(i8* %6, i8** %3, i32 10)
  store i64 %7, i64* %4, align 8
  %8 = call i32* @__error()
  %9 = load i32, i32* %8, align 4
  %10 = icmp eq i32 %9, 34
  br i1 %10, label %11, label %17

; <label>:11                                      ; preds = %1
  %12 = load i64, i64* %4, align 8
  %13 = icmp eq i64 %12, 9223372036854775807
  br i1 %13, label %24, label %14

; <label>:14                                      ; preds = %11
  %15 = load i64, i64* %4, align 8
  %16 = icmp eq i64 %15, -9223372036854775808
  br i1 %16, label %24, label %17

; <label>:17                                      ; preds = %14, %1
  %18 = call i32* @__error()
  %19 = load i32, i32* %18, align 4
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %21, label %25

; <label>:21                                      ; preds = %17
  %22 = load i64, i64* %4, align 8
  %23 = icmp eq i64 %22, 0
  br i1 %23, label %24, label %25

; <label>:24                                      ; preds = %21, %14, %11
  call void @perror(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str, i32 0, i32 0))
  call void @exit(i32 1) #3
  unreachable

; <label>:25                                      ; preds = %21, %17
  %26 = load i64, i64* %4, align 8
  ret i64 %26
}

declare i32* @__error() #1

declare i64 @strtoll(i8*, i8**, i32) #1

declare void @perror(i8*) #1

; Function Attrs: noreturn
declare void @exit(i32) #2

; Function Attrs: nounwind ssp uwtable
define i32 @main(i32, i8**) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i8**, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %7 = alloca i64, align 8
  %8 = alloca i64, align 8
  %9 = alloca i64, align 8
  %10 = alloca i64, align 8
  %11 = alloca i64, align 8
  %12 = alloca i64, align 8
  %13 = alloca i64, align 8
  store i32 %0, i32* %3, align 4
  store i8** %1, i8*** %4, align 8
  %14 = load i32, i32* %3, align 4
  %15 = icmp ne i32 %14, 9
  br i1 %15, label %16, label %18

; <label>:16                                      ; preds = %2
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([29 x i8], [29 x i8]* @.str.1, i32 0, i32 0), i32 8)
  call void @exit(i32 0) #3
  unreachable

; <label>:18                                      ; preds = %2
  %19 = load i8**, i8*** %4, align 8
  %20 = getelementptr inbounds i8*, i8** %19, i64 1
  %21 = load i8*, i8** %20, align 8
  %22 = call i64 @get_int64(i8* %21)
  store i64 %22, i64* %5, align 8
  %23 = load i8**, i8*** %4, align 8
  %24 = getelementptr inbounds i8*, i8** %23, i64 2
  %25 = load i8*, i8** %24, align 8
  %26 = call i64 @get_int64(i8* %25)
  store i64 %26, i64* %6, align 8
  %27 = load i8**, i8*** %4, align 8
  %28 = getelementptr inbounds i8*, i8** %27, i64 3
  %29 = load i8*, i8** %28, align 8
  %30 = call i64 @get_int64(i8* %29)
  store i64 %30, i64* %7, align 8
  %31 = load i8**, i8*** %4, align 8
  %32 = getelementptr inbounds i8*, i8** %31, i64 4
  %33 = load i8*, i8** %32, align 8
  %34 = call i64 @get_int64(i8* %33)
  store i64 %34, i64* %8, align 8
  %35 = load i8**, i8*** %4, align 8
  %36 = getelementptr inbounds i8*, i8** %35, i64 5
  %37 = load i8*, i8** %36, align 8
  %38 = call i64 @get_int64(i8* %37)
  store i64 %38, i64* %9, align 8
  %39 = load i8**, i8*** %4, align 8
  %40 = getelementptr inbounds i8*, i8** %39, i64 6
  %41 = load i8*, i8** %40, align 8
  %42 = call i64 @get_int64(i8* %41)
  store i64 %42, i64* %10, align 8
  %43 = load i8**, i8*** %4, align 8
  %44 = getelementptr inbounds i8*, i8** %43, i64 7
  %45 = load i8*, i8** %44, align 8
  %46 = call i64 @get_int64(i8* %45)
  store i64 %46, i64* %11, align 8
  %47 = load i8**, i8*** %4, align 8
  %48 = getelementptr inbounds i8*, i8** %47, i64 8
  %49 = load i8*, i8** %48, align 8
  %50 = call i64 @get_int64(i8* %49)
  store i64 %50, i64* %12, align 8
  %51 = load i64, i64* %5, align 8
  %52 = load i64, i64* %6, align 8
  %53 = load i64, i64* %7, align 8
  %54 = load i64, i64* %8, align 8
  %55 = load i64, i64* %9, align 8
  %56 = load i64, i64* %10, align 8
  %57 = load i64, i64* %11, align 8
  %58 = load i64, i64* %12, align 8
  %59 = call i64 @program(i64 %51, i64 %52, i64 %53, i64 %54, i64 %55, i64 %56, i64 %57, i64 %58)
  store i64 %59, i64* %13, align 8
  %60 = load i64, i64* %13, align 8
  %61 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.2, i32 0, i32 0), i64 %60)
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

declare i64 @program(i64, i64, i64, i64, i64, i64, i64, i64) #1

attributes #0 = { nounwind ssp uwtable "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noreturn "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sse,+sse2,+sse3,+sse4.1,+ssse3" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"PIC Level", i32 2}
!1 = !{!"Apple LLVM version 8.0.0 (clang-800.0.42.1)"}
