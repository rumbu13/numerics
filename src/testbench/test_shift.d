module test_shift;

import mixins;import std.format;
import std.conv;
import std.stdio;
import std.datetime;
import mixins;

enum samples = 100;
enum minBits = 96;
enum maxBits = 1024;

mixin(genArrayTypes(minBits, maxBits));
mixin(genArrayVariables(minBits, maxBits, samples));


@safe pure nothrow @nogc
void shl_gen(uint[] x, const size_t y)
{
    assert(x.length);
    assert(y);
    assert(y < x.length * 32);

    immutable bigShift = y / 32;
    immutable smallShift = y % 32;

    if (smallShift == 0) 
    {
        for (ptrdiff_t i = x.length - 1; i >= bigShift; --i) 
            x[i] = x[i - bigShift]; 
    }
    else
    { 
        immutable carryShift = 32 - smallShift;
        ptrdiff_t i;
        for (i = x.length - 1; i > bigShift; --i) 
        {
            x[i] = (x[i - bigShift] << smallShift);
            x[i] |= (x[i - bigShift - 1] >>> carryShift); 
        }
        x[i] = x[i - bigShift] << smallShift;
    }             

    if (bigShift > 0)
        x[0 .. bigShift] = 0;
}


@safe pure nothrow @nogc
void shl_x86_1(uint[] x, const size_t y)
{
    enum pushes = 4;
    enum last_param = pushes * 4 + 4;
    enum xlen = last_param + 0 * 4;
    enum xptr = last_param + 1 * 4;
    asm @safe pure nothrow @nogc
    {
        naked;
        push ESI;
        push EDI;
        push EBX;
        push EBP;
        mov ECX, EAX;
        mov EDX, dword ptr [ESP + xlen];
        shr ECX, 5;                         //ECX = big shift (32 bits)
        and EAX, 31;                        //EAX = small shift
        mov EDI, dword ptr [ESP + xptr];
        lea EDI, [EDI + EDX * 4 - 4];       //EDI = last element
        lea ESI, [EDI - ECX * 4];           //ESI = EDI - big shift
        push ECX;                           //save big shift for zero fill                           
        neg ECX;
        add ECX, EDX;                       //ECX = len - big shift

        test EAX, EAX;
        jz full_shift;

        mov EBX, ECX;
        mov CL, AL;
        xor EBP, EBP;
        sub EBX, 1;
        test EBX, EBX;
        jz remaining_shift;

        mov EDX, dword ptr [ESI - 4];
    complex_shift:
        
        
        shld EAX, EDX, CL;
        mov dword ptr [EDI], EAX;
        sub ESI, 4;
        sub EDI, 4;
        sub EBP, 1;
        cmp EBP, EBX;
        jb complex_shift;
    remaining_shift:
        mov EAX, dword ptr [ESI];
        shl EAX, CL;
        mov dword ptr [EDI], EAX;
        jmp zero_fill;
    full_shift:     
        std;
        rep;
        movsd;
        cld;
    zero_fill:
        pop ECX;
        xor EAX, EAX;
        mov EDI, dword ptr [ESP + xptr];
        rep;
        stosd;
     cleanup:
        pop EBP;
        pop EBX;
        pop EDI;
        pop ESI;
        ret 2 * 4;
    }
}


void test_shl(uint bits, string func)()
{
    for (size_t i = 0; i < samples; ++i)
        mixin(format("%s(arrays%d[i], 36);", func, bits));
}

string genBenchmark1(uint bits)
{
    return format("comparingBenchmark!(test_shl!(%d, \"shl_gen\"), test_shl!(%d,\"shl_x86_1\"))", bits, bits);
}

string genBenchmark2(uint bits)
{
    return format("comparingBenchmark!(test_shl!(%d, \"shl_gen\"), test_shl!(%d,\"shl_x86_1\"))", bits, bits);
}

string genBenchmark3(uint bits)
{
    return format("comparingBenchmark!(test_shl!(%d, \"shl_gen\"), test_shl!(%d,\"shl_x86_1\"))", bits, bits);
}

string genBenchmark4(uint bits)
{
    return format("comparingBenchmark!(test_shl!(%d, \"shl_gen\"), test_shl!(%d,\"shl_x86_1\"))", bits, bits);
}

string genBenchmark5(uint bits)
{
    return format("comparingBenchmark!(test_shl!(%d, \"shl_gen\"), test_shl!(%d,\"shl_x86_1\"))", bits, bits);
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