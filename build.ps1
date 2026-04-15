param(
    [string]$Compiler = "C:\Program Files\LLVM\bin\clang.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Compiler)) {
    throw "clang.exe를 찾을 수 없습니다: $Compiler"
}

$common = @(
    "-D_CRT_SECURE_NO_WARNINGS",
    "-std=c11",
    "-Wall",
    "-Wextra",
    "-pedantic",
    "-Iinclude"
)

$shared = @(
    "src\engine.c",
    "src\util.c",
    "src\ast.c",
    "src\tokenizer.c",
    "src\parser.c",
    "src\optimizer.c",
    "src\storage.c",
    "src\executor.c",
    "src\database.c",
    "src\bptree.c"
)

& $Compiler @common "src\main.c" @shared "-o" "mini_sql.exe"
& $Compiler @common "src\test_main.c" @shared "-o" "mini_sql_tests.exe"
& $Compiler @common "src\benchmark_main.c" @shared "-o" "mini_sql_benchmark.exe"

Write-Host "Built mini_sql.exe, mini_sql_tests.exe, mini_sql_benchmark.exe"
