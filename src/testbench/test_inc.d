module test_inc;


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

uint[samples] results;


@safe pure nothrow @nogc
uint inc_gen(uint[] x)
{
    for (size_t i = 0; i < x.length; ++i)
        if (++x[i])
            return 0;
    return 1;
    
}

@safe pure nothrow @nogc
uint inc_x86_1(uint[] x)
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
        jz carry;
        mov EDX, dword ptr [ESP + xptr];
        lea EDX, [EDX + ECX * 4];
        neg ECX;
    inc_loop:
        inc dword ptr [EDX + ECX * 4];
        jnz no_carry;
        add ECX, 1;
        jnz inc_loop;
        jmp carry;
    no_carry:
        xor EAX, EAX;
        jmp cleanup;
    carry:
        mov EAX, 1;
    cleanup:
        ret 2 * 4;
    }
}

@safe pure nothrow @nogc
uint inc_x86_2(uint[] x)
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
        jz carry;
        mov EDX, dword ptr [ESP + xptr];
        xor EAX, EAX;
    inc_loop:
        inc dword ptr [EDX + EAX * 4];
        jnz no_carry;
        add EAX, 1;
        cmp EAX, ECX;
        jb inc_loop;
        jmp carry;
    no_carry:
        xor EAX, EAX;
        ret 2 * 4;
    carry:
        mov EAX, 1;
    cleanup:
        ret 2 * 4;
    }
}

@safe pure nothrow @nogc
uint inc_x86_3(uint[] x)
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
        jz carry;
        mov EDX, dword ptr [ESP + xptr];
        xor EAX, EAX;
    inc_loop:
        inc dword ptr [EDX + EAX * 4];
        jnz no_carry;
        inc EAX;
        cmp EAX, ECX;
        jb inc_loop;
        jmp carry;
    no_carry:
        xor EAX, EAX;
        ret 2 * 4;
    carry:
        mov EAX, 1;
        ret 2 * 4;
    }
}

@safe pure nothrow @nogc
uint inc_x86_4(uint[] x)
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
        jz carry;
        mov EDX, dword ptr [ESP + xptr];
        inc dword ptr [EDX];
        jnz no_carry;
        mov EAX, 1;
        cmp EAX, ECX;
        jae carry;
    inc_loop:
        inc dword ptr [EDX + EAX * 4];
        jnz no_carry;
        inc EAX;
        cmp EAX, ECX;
        jb inc_loop;
        jmp carry;
    no_carry:
        xor EAX, EAX;
        ret 2 * 4;
    carry:
        mov EAX, 1;
    cleanup:
        ret 2 * 4;
    }
}


void test_inc(uint bits, string func)()
{
    for (size_t i = 0; i < samples; ++i)
        mixin(format("results[i] = %s(arrays%d[i]);", func, bits));
}

string genBenchmark1(uint bits)
{
    return format("comparingBenchmark!(test_inc!(%d, \"inc_gen\"), test_inc!(%d,\"inc_x86_1\"))", bits, bits);
}

string genBenchmark2(uint bits)
{
    return format("comparingBenchmark!(test_inc!(%d, \"inc_gen\"), test_inc!(%d,\"inc_x86_2\"))", bits, bits);
}

string genBenchmark3(uint bits)
{
    return format("comparingBenchmark!(test_inc!(%d, \"inc_gen\"), test_inc!(%d,\"inc_x86_3\"))", bits, bits);
}

string genBenchmark4(uint bits)
{
    return format("comparingBenchmark!(test_inc!(%d, \"inc_gen\"), test_inc!(%d,\"inc_x86_4\"))", bits, bits);
}

string genBenchmark5(uint bits)
{
    return format("comparingBenchmark!(test_inc!(%d, \"inc_gen\"), test_inc!(%d,\"inc_x86_1\"))", bits, bits);
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