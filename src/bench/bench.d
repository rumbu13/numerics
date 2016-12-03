import std.stdio;

import std.typetuple;
import std.bigint;
import std.conv;
import numerics.fixed;
import std.datetime;
import std.random;

alias uint96 = FixedInt!(96, false);
alias uint128 = FixedInt!(128, false);
alias uint256 = FixedInt!(256, false);
alias uint1024 = FixedInt!(1024, false);

alias int96 = FixedInt!(96, true);
alias int128 = FixedInt!(128, true);
alias int256 = FixedInt!(256, true);
alias int1024 = FixedInt!(1024, true);

alias fixedTypes = TypeTuple!(uint96, int96, uint128, int128, uint256, int256, uint1024, int1024);
alias allTypes = TypeTuple!(BigInt, fixedTypes);

string prettyName(T)()
{
    static if (is(T: FixedInt!(bits, signed), uint bits, bool signed))
        return (signed? "int" : "uint") ~ to!string(bits);
    else
        return T.stringof;
}

string prefix(T, uint size = 0, bool sign = true)()
{
    static if (is(T: FixedInt!(bits, signed), uint bits, bool signed))
        return prettyName!T();
    else
        return size ? T.stringof ~ to!string(size) ~ (sign ? "u" : "i") : T.stringof;

}

T genRandom(T)() if (isFixedInt!T)
{
    T x;
    for (size_t i = 0 ; i < T.sizeof / 4; ++i)
    {
        x |= uniform!uint;
        if (i < T.sizeof / 4 - 1)
            x <<= 32;
    }
    return x;
}

T genRandom(T)() if (is(T == BigInt))
{
    T x;
    auto ints = uniform(3, 33);
    for (size_t i = 0 ; i < ints; ++i)
    {
        x |= uniform!uint;
        if (i < ints - 1)
            x <<= 32;
    }
    return x;
}

BigInt genRandomBig(uint size)()
{
    BigInt x;
    auto ints = size / 32;
    for (size_t i = 0 ; i < ints; ++i)
    {
        x |= uniform!uint;
        if (i < ints - 1)
            x <<= 32;
    }
    return x;
}




enum samples = 1000;

uint[samples] uintvals;
int[samples] intvals;

ulong[samples] ulongvals;
long[samples] longvals;

uint[samples] uintdata;
int[samples] intdata;

ulong[samples] ulongdata;
long[samples] longdata;

string[samples] strdata;
string[samples] strdata2;

BigInt[samples] BigIntvals;
BigInt[samples] BigIntdata;
BigInt[samples] BigIntdata2;



bool[samples] booldata;
bool[samples] booldata2;

string genarrays()
{
    string s;
    foreach(T; fixedTypes)
    {
        s ~= prettyName!T() ~ "[samples] " ~ prettyName!T() ~ "vals;\n" ~
             prettyName!T() ~ "[samples] " ~ prettyName!T() ~ "data;\n" ~
             prettyName!T() ~ "[samples] " ~ prettyName!T() ~ "data2;\n";
        s ~= "BigInt[samples] " ~ prefix!(BigInt, T.sizeof * 8, isSignedFixedInt!T) ~ "vals;\n" ~
             "BigInt[samples] " ~ prefix!(BigInt, T.sizeof * 8, isSignedFixedInt!T) ~ "data;\n" ~
             "BigInt[samples] " ~ prefix!(BigInt, T.sizeof * 8, isSignedFixedInt!T) ~ "data2;\n";
    }
    return s;
}

mixin(genarrays());

void testintctor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = T(uintvals[i]);"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = T(intvals[i]);"); 
    }
}

void testlongctor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = T(ulongvals[i]);"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = T(longvals[i]);"); 
    }
}

void testselfctor(T, uint size = 0, bool signed = true)()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed) ~ "data[i] = T(" ~ prefix!(T, size, signed)  ~ "vals[i]);");
    }
}

void teststrctor(T, uint size = 0, bool signed = true) ()
{
    mixin(prefix!(T, size, signed) ~ "data[0] = T(\"123456\");");
    mixin(prefix!(T, size, signed) ~ "data[1] = T(\"-123456\");");
    mixin(prefix!(T, size, signed) ~ "data[2] = T(\"12345678901234567890123456789\");");
    mixin(prefix!(T, size, signed) ~ "data[3] = T(\"-12345678901234567890123456789\");");
    mixin(prefix!(T, size, signed) ~ "data[4] = T(\"1_2_3_4_5_6\");");
    mixin(prefix!(T, size, signed) ~ "data[5] = T(\"-1_2_3_4_5_6\");");
    mixin(prefix!(T, size, signed) ~ "data[6] = T(\"1_2_3_4_5_6_7_8_9_0_1_2_3_4_5_6_7_8_9_0_1_2_3_4_5_6_7_8_9\");");
    mixin(prefix!(T, size, signed) ~ "data[7] = T(\"-1_2_3_4_5_6_7_8_9_0_1_2_3_4_5_6_7_8_9_0_1_2_3_4_5_6_7_8_9\");");
    mixin(prefix!(T, size, signed) ~ "data[8] = T(\"0x9ABCDEF\");");
    mixin(prefix!(T, size, signed) ~ "data[9] = T(\"0x9_A_B_C_D_E_F\");");
    mixin(prefix!(T, size, signed) ~ "data[10] = T(\"0xAAAABBBBCCCCDDDDEEEEFFFF\");");
    mixin(prefix!(T, size, signed) ~ "data[11] = T(\"0xA_A_A_A_B_B_B_B_C_C_C_C_D_D_D_D_E_E_E_E_F_F_F_F\");");
}

void testintassign(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = intvals[i];"); 
    }
}

void testlongassign(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = longvals[i];"); 
    }
}

void testselfassign(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = " ~ prefix!(T, size, signed)  ~ "vals[i];");
    }
}

void testintequ(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("booldata[i] = " ~ prefix!(T, size, signed)() ~ "data[i] == uintvals[i];");
        mixin("booldata2[i] = " ~ prefix!(T, size, signed)() ~ "data2[i] == intvals[i];");
    }
}

void testlongequ(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("booldata[i] = " ~ prefix!(T, size, signed)() ~ "data[i] == ulongvals[i];");
        mixin("booldata2[i] = " ~ prefix!(T, size, signed)() ~ "data2[i] == longvals[i];");
    }
}

void testselfequ(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("booldata[i] = " ~ prefix!(T, size, signed)() ~ "data[i] == " ~ prefix!(T, size, signed)() ~ "data2[i];");
    }
}

void testintcmp(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("booldata[i] = " ~ prefix!(T, size, signed)() ~ "data[i] > uintvals[i];");
        mixin("booldata2[i] = " ~ prefix!(T, size, signed)() ~ "data2[i] > intvals[i];");
    }
}

void testlongcmp(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("booldata[i] = " ~ prefix!(T, size, signed)() ~ "data[i] > ulongvals[i];");
        mixin("booldata2[i] = " ~ prefix!(T, size, signed)() ~ "data2[i] > longvals[i];");
    }
}

void testselfcmp(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("booldata[i] = " ~ prefix!(T, size, signed)() ~ "data[i] > " ~ prefix!(T, size, signed)() ~ "data2[i];");
    }
}

void testnot(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = ~" ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testneg(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = -" ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testinc(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("++" ~ prefix!(T, size, signed)() ~ "data[i];"); 
    }
}

void testdec(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("--" ~ prefix!(T, size, signed)() ~ "data[i];"); 
    }
}

void testintcast(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        static if (is(T == BigInt))
        {
            mixin("uintdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toInt();"); 
            mixin("intdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toInt();"); 
        }
        else
        {
            mixin("uintdata[i] = cast(uint)" ~ prettyName!T() ~ "vals[i];"); 
            mixin("intdata[i] = cast(int)" ~ prettyName!T() ~ "vals[i];"); 
        }
    }
}

void testlongcast(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        static if (is(T == BigInt))
        {
            mixin("ulongdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toLong();"); 
            mixin("longdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toLong();"); 
        }
        else
        {
            mixin("ulongdata[i] = cast(ulong)" ~ prettyName!T() ~ "vals[i];"); 
            mixin("longdata[i] = cast(long)" ~ prettyName!T() ~ "vals[i];"); 
        }
    }
}

void testselfcast(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] = " ~ "cast(" ~ T.stringof ~ ")" ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] |= uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] |= intvals[i];"); 
    }
}

void testlongor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] |= ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] |= longvals[i];"); 
    }
}

void testselfor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] |= " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintand(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] &= uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] &= intvals[i];"); 
    }
}

void testlongand(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] &= ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] &= longvals[i];"); 
    }
}

void testselfand(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] &= " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintxor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] ^= uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] ^= intvals[i];"); 
    }
}

void testlongxor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] ^= ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] ^= longvals[i];"); 
    }
}

void testselfxor(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] ^= " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintadd(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] += uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] += intvals[i];"); 
    }
}

void testlongadd(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] += ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] += longvals[i];"); 
    }
}

void testselfadd(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] += " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintsub(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] -= uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] -= intvals[i];"); 
    }
}

void testlongsub(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] -= ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] -= longvals[i];"); 
    }
}

void testselfsub(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] -= " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintmul(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] * uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] * intvals[i];"); 
    }
}

void testlongmul(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] * ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] * longvals[i];"); 
    }
}

void testselfmul(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] * " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintdiv(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] / uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] / intvals[i];"); 
    }
}

void testlongdiv(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] / ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] / longvals[i];"); 
    }
}

void testselfdiv(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)()~ "data[i] / " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testintrem(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] % uintvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] % intvals[i];"); 
    }
}

void testlongrem(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] % ulongvals[i];"); 
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] % longvals[i];"); 
    }
}

void testselfrem(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data2[i] = " ~ prefix!(T, size, signed)() ~ "data[i] % " ~ prefix!(T, size, signed)() ~ "vals[i];"); 
    }
}

void testshift(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin(prefix!(T, size, signed)() ~ "data[i] <<= 32;");
        mixin(prefix!(T, size, signed)() ~ "data2[i] >>= 32;");
        mixin(prefix!(T, size, signed)() ~ "data[i] <<= 4;");
        mixin(prefix!(T, size, signed)() ~ "data2[i] >>= 4;");
        mixin(prefix!(T, size, signed)() ~ "data[i] >>= 36;");
        mixin(prefix!(T, size, signed)() ~ "data2[i] <<= 36;");
    }
}

void testtostring(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        static if (is(T == BigInt))
            mixin("strdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toDecimalString();"); 
        else
            mixin("strdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toString();"); 
    }
}

void testtohex(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        static if (is(T == BigInt))
            mixin("strdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toHex();"); 
        else
            mixin("strdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].to!string(16);"); 
    }
}

//void testfmt(T, uint size = 0, bool signed = true) ()
//{
//    for(size_t i = 0; i < samples; ++i)
//    {
//        mixin("strdata[i] = format(\"%d\"," ~ prettyName!T() ~ "vals[i]);"); 
//        mixin("strdata2[i] = format(\"%x\"," ~ prettyName!T() ~ "vals[i]);"); 
//        mixin("strdata[i] = format(\"%X\"," ~ prettyName!T() ~ "vals[i]);"); 
//    }
//}

void testtohash(T, uint size = 0, bool signed = true) ()
{
    for(size_t i = 0; i < samples; ++i)
    {
        mixin("ulongdata[i] = " ~ prefix!(T, size, signed)() ~ "vals[i].toHash();"); 
    }
}

string gentest(string title, string func)
{
    return format(q{
        writef("%%10s", "%s");
        writef("%%9.2f", 1.0);
        foreach(T; fixedTypes)
        {
            writef("%%9.2f", comparingBenchmark!(%s!(BigInt, T.sizeof * 8, isSignedFixedInt!T), %s!T, 100).point);
        }
        writeln();
    }, title, func, func);
}

int main(string[] argv)
{
    for (size_t i = 0; i < samples; ++i)
    {
        uintvals[i] = uniform!uint();
        intvals[i] = uniform!int();
        ulongvals[i] = uniform!ulong();
        longvals[i] = uniform!long();
        BigIntvals[i] = genRandom!BigInt();
        foreach(T; fixedTypes)
        {
            mixin(prettyName!T() ~ "vals[i] = genRandom!(" ~ T.stringof ~ ")();"); 
            mixin(prefix!(BigInt, T.sizeof * 8, isSignedFixedInt!T) ~ "vals[i] = genRandomBig!(T.sizeof * 8)();");
        }
    }

    writef("%10s", "Operation");
    foreach(T; allTypes)
    {
        writef("%9s", prettyName!T);
    }
    writeln();

    mixin(gentest("int ctor", "testintctor"));
    mixin(gentest("long ctor", "testlongctor"));
    mixin(gentest("self ctor", "testselfctor"));
    mixin(gentest("str ctor", "teststrctor"));
    mixin(gentest("int =", "testintassign"));
    mixin(gentest("long =", "testlongassign"));
    mixin(gentest("self =", "testselfassign"));
    mixin(gentest("int ==", "testintequ"));
    mixin(gentest("long ==", "testlongequ"));
    mixin(gentest("self ==", "testselfequ"));
    mixin(gentest("int <>", "testintcmp"));
    mixin(gentest("long <>", "testlongcmp"));
    mixin(gentest("self <>", "testselfcmp"));
    mixin(gentest("~", "testnot"));
    mixin(gentest("-", "testneg"));
    mixin(gentest("++", "testinc"));
    mixin(gentest("--", "testdec"));
    mixin(gentest("int cast", "testintcast"));
    mixin(gentest("long cast", "testlongcast"));
    mixin(gentest("self cast", "testselfcast"));
    mixin(gentest("int |", "testintor"));
    mixin(gentest("long |", "testlongor"));
    mixin(gentest("self |", "testselfor"));
    mixin(gentest("int &", "testintand"));
    mixin(gentest("long &", "testlongand"));
    mixin(gentest("self &", "testselfand"));
    mixin(gentest("int ^", "testintxor"));
    mixin(gentest("long ^", "testlongxor"));
    mixin(gentest("self ^", "testselfxor"));
    mixin(gentest("<< >>", "testshift"));
    mixin(gentest("int +", "testintadd"));
    mixin(gentest("long +", "testlongadd"));
    mixin(gentest("self +", "testselfadd"));
    mixin(gentest("int -", "testintsub"));
    mixin(gentest("long -", "testlongsub"));
    mixin(gentest("self -", "testselfsub"));
    mixin(gentest("int *", "testintmul"));
    mixin(gentest("long *", "testlongmul"));
    mixin(gentest("self *", "testselfmul"));
    mixin(gentest("int /", "testintdiv"));
    mixin(gentest("long /", "testlongdiv"));
    mixin(gentest("self /", "testselfdiv"));
    mixin(gentest("int %", "testintrem"));
    mixin(gentest("long %", "testlongrem"));
    mixin(gentest("self %", "testselfrem"));
    mixin(gentest("tostring", "testtostring"));
    mixin(gentest("tohex", "testtohex"));
    mixin(gentest("hash", "testtohash"));

    somefunc(0xCCCCCCCC, 0xAAAAAAAABBBBBBBB);
   

    writeln("Press any key to continue");
    getchar();
    return 0;

}


void somefunc(uint x, ulong y)
{
    //
}