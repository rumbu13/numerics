module test_all;

import std.format;
import std.conv;
import std.stdio;
import std.datetime;
import mixins;

enum samples = 100;
enum minBits = 96;
enum maxBits = 1024;

mixin(genArrayTypes(minBits, maxBits));
mixin(genArrayVariables(minBits, maxBits, samples));

bool[samples] results;

pragma(inline, false)
@safe pure nothrow @nogc
private bool all_gen(const(uint)[] x, const uint y)
{
    for(size_t i = 0; i < x.length; ++i)
        if (x[i] != y)
            return false;
    return true;
}

@safe pure nothrow @nogc
bool all_x86(const(uint)[] x, const uint y)
{
    enum pushes = 0;
    enum last_param = pushes * 4 + 4;
    enum xlen = last_param + 0 * 4;
    enum xptr = last_param + 1 * 4;

    asm @safe pure nothrow @nogc
    {
        naked;
        mov ECX, dword ptr [ESP + xlen];
        test ECX, ECX;
        jz yes_all;
        mov EDX, dword ptr [ESP + xptr];
        lea EDX, [EDX + ECX * 4];
        neg ECX;
    all_loop:
        cmp dword ptr [EDX + ECX * 4], EAX;
        jne not_all;
        add ECX, 1;
        jnz all_loop;
        jmp yes_all;
    not_all:
        xor AL, AL;
        jmp cleanup;
    yes_all:
        mov AL, 1;
    cleanup:
        ret 2 * 4;
    }
}



@safe pure nothrow @nogc
bool all_x86_2(const(uint)[] x, const uint y)
{
    enum pushes = 1;
    enum last_param = pushes * 4 + 4;
    enum xlen = last_param + 0 * 4;
    enum xptr = last_param + 1 * 4;

    asm @safe pure nothrow @nogc
    {
        naked;
        push EDI;
        mov EDI, dword ptr [ESP + xptr];
        mov ECX, dword ptr [ESP + xlen];
        repe;
        scasd;
        jne not_all;
        mov EAX, 1;
        jmp cleanup;
    not_all:
        xor EAX, EAX;
    cleanup:
        pop EDI;
        ret 2 * 4;
    }
}


@safe pure nothrow @nogc
bool all_x86_3(const(uint)[] x, const uint y)
{
    enum pushes = 1;
    enum last_param = pushes * 4 + 4;
    enum xlen = last_param + 0 * 4;
    enum xptr = last_param + 1 * 4;

    asm @safe pure nothrow @nogc
    {
        naked;
        push EBX;
        mov ECX, dword ptr [ESP + xlen];
        test ECX, ECX;
        jz cleanup;
        xor EBX, EBX;
        mov EDX, dword ptr [ESP + xptr];
    all_loop:
        cmp EAX, dword ptr [EDX + EBX * 4];
        jne cleanup;
        inc EBX;
        cmp EBX, ECX;
        jb all_loop;
    all_true:
        mov EAX, 1;
        pop EBX;
        ret 2 * 4;
    cleanup:
        xor EAX, EAX;
        pop EBX;
        ret 2 * 4;
    }
}


@safe pure nothrow @nogc
bool all_x86_4(const(uint)[] x, const uint y)
{
    enum pushes = 0;
    enum last_param = pushes * 4 + 4;
    enum xlen = last_param + 0 * 4;
    enum xptr = last_param + 1 * 4;

    asm @safe pure nothrow @nogc
    {
        naked;
        mov ECX, dword ptr [ESP + xlen];
        jz return_true;
        mov EDX, dword ptr [ESP + xptr];
        cmp EAX, dword ptr [EDX];
        jne return_false;;
        sub ECX, 1;
        jz return_true;
        lea EDX, [EDX + ECX * 4];
        neg ECX;
    all_loop:
        cmp EAX, dword ptr [EDX + ECX * 4];
        jne return_false;
        add ECX, 1;
        jnz all_loop;
    return_true:
        mov AL, 1;
        ret 2 * 4;
    return_false:
        xor AL, AL;
        ret 2 * 4;
    }
}

@safe pure nothrow @nogc
bool all_x86_5(const(uint)[] x, const uint y)
{
    enum pushes = 0;
    enum last_param = pushes * 4 + 4;
    enum xlen = last_param + 0 * 4;
    enum xptr = last_param + 1 * 4;

    asm @safe pure nothrow @nogc
    {
        naked;
        cmp dword ptr [ESP + xlen], 0;
        je return_true;
        mov EDX, dword ptr [ESP + xptr];
        xor ECX, ECX;
    check:
        cmp EAX, dword ptr [EDX + ECX * 4];
        jne return_false;
        inc ECX;
        cmp ECX, dword ptr [ESP + xlen];
        jb check;
    return_true:
        mov EAX, 1;
        ret 2 * 4;
    return_false:
        xor EAX, EAX;
        ret 2 * 4;
    }
}

void test_all(uint bits, string func)()
{
    for (size_t i = 0; i < samples; ++i)
        mixin(format("results[i] = %s(arrays%d[i], 0);", func, bits));
}

string genBenchmark1(uint bits)
{
    return format("comparingBenchmark!(test_all!(%d, \"all_gen\"), test_all!(%d,\"all_x86\"))", bits, bits);
}

string genBenchmark2(uint bits)
{
    return format("comparingBenchmark!(test_all!(%d, \"all_gen\"), test_all!(%d,\"all_x86_2\"))", bits, bits);
}

string genBenchmark3(uint bits)
{
    return format("comparingBenchmark!(test_all!(%d, \"all_gen\"), test_all!(%d,\"all_x86_3\"))", bits, bits);
}

string genBenchmark4(uint bits)
{
    return format("comparingBenchmark!(test_all!(%d, \"all_gen\"), test_all!(%d,\"all_x86_4\"))", bits, bits);
}

string genBenchmark5(uint bits)
{
    return format("comparingBenchmark!(test_all!(%d, \"all_gen\"), test_all!(%d,\"all_x86_5\"))", bits, bits);
}

string genOutput()
{
    string s;
    for (uint bits = minBits; bits <= maxBits; bits += 32)
    {
        s ~= "writefln(\"%d bits: %6.2f %6.2f %6.2f %6.2f %6.2f\", " ~  to!string(bits) ~", " ~ 
            genBenchmark1(bits) ~ ".point, " ~ 
            genBenchmark2(bits) ~ ".point, " ~ 
            genBenchmark3(bits) ~ ".point, " ~ 
            genBenchmark4(bits) ~ ".point, " ~ 
            genBenchmark5(bits) ~ ".point);\n";
    }
    return s;
}

void perform()
{
    mixin(genOutput());
}


static this()
{
    mixin(genRandomizeArrays(minBits, maxBits, samples));
}

//@safe pure nothrow @nogc
//bool all_x64_1(const(uint)[] x, const uint y)
//{
//    //Windows: RCX, RDX, R8
//    //Linux: RDI, RSI, RDX
//    asm @safe pure nothrow @nogc
//    {
//        test RDX, RDX;
//        jz return_true;
//        cmp dword ptr [RCX], R8D;
//        jne return_false;
//        sub RDX, 1;
//        jz return_true;
//        mov RAX, RDX;
//        shr RAX, 1;
//        test RAX, RAX;
//        jz compare_one;
//        lea RCX, [RCX + RAX * 8];
//        neg RAX;
//        mov R9, R8;
//        shl R9, 32;
//        mov R9D, R8D;
//    compare_two:
//        cmp R9, qword ptr [RCX + RAX * 8];
//        jne return_false;
//        add RAX, 1;
//        jnz compare_two;
//    compare_one:
//        lea RCX, [RCX + RDX * 8];
//        sub RCX, 4;
//        cmp R8D, dword ptr [RCX];
//        jne return_false;
//    return_true:
//        mov EAX, 1;
//        ret;
//    return_false:
//        xor EAX, EAX;
//        ret;
//    }
//}