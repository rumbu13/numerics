// Written in the D programming language.


/**
*
* Copyright: Copyright Răzvan Ștefănescu 2016
*
* License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
*
* Authors: $(LINK2 rumbu.ro, Răzvan Ștefănescu)
*
* Source: $(GITHUBREF fixed/_package.d, package.d)
*
* Macros:
*   LOCALREF   = <a href="#$0">$0</a>
*   LOCALMREF  = <a href="#$1.$2">$2</a>
*   LOCALMREF2 = <a href="#$1.$2">$3</a>
*   PHOBOSREF  = <a href="https://dlang.org/phobos/std_$1.html#$2">$2</a>
*   GITHUBREF  = <a href="https://github.com/rumbu13/$1">$+</a>
*
*   DDOC = <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
*           <html>
*           <head>
*            <meta charset="utf-8">
*           <title>$(TITLE)</title>
*           <link rel="stylesheet" href="https://dlang.org/css/codemirror.css">
*           <link rel="stylesheet" href="https://dlang.org/css/style.css">
*           <link rel="stylesheet" href="https://dlang.org/css/print.css" media="print">
*           <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=0.1, maximum-scale=10.0">
*           </head>
*           <body>
*           <h1>$(TITLE)</h1>
*           $(BODY)
*           </body></html>
*/
module numerics.fixed;

public import std.traits: isIntegral, isSomeChar, isSomeString, isFloatingPoint, Unqual, isSigned, isUnsigned, Unsigned, Signed, isArray;
public import std.format: FormatSpec, FormatException, format;
public import std.conv: ConvException, ConvOverflowException;
public import std.ascii: LetterCase;
public import std.range: isInputRange, ElementType;
import core.stdc.string: memcpy;

private import numerics.internal.chars;
private import numerics.internal.strings;
private import numerics.internal.integrals;
private import numerics.internal.arrays;
private import numerics.internal.floats;
private import std.math: log, floor;

private alias ispow2 = numerics.internal.integrals.ispow2;
private alias clz    = numerics.internal.integrals.clz;
private alias ctz    = numerics.internal.integrals.ctz;

private alias ispow2 = numerics.internal.arrays.ispow2;
private alias clz    = numerics.internal.arrays.clz;
private alias ctz    = numerics.internal.arrays.ctz;

version(unittest)
{
    alias uint96 = FixedInt!(96, false);
    alias uint128 = FixedInt!(128, false);
    alias uint160 = FixedInt!(160, false);
    alias int96 = FixedInt!(96, true);
    alias int128 = FixedInt!(128, true);
    alias int160 = FixedInt!(160, true);
}


/** 

* The FixedInt type is a type that represents a fixed size integer.
* FixedInt type implements all the arithmentic operations specific to 
* other integral types
* Params:
*  bits   =   type size, all positive multiples of 32 are accepted, except 32
*             and 64 because these are equivalent to builtin types
*             $(D_KEYWORD int) and $(D_KEYWORD long) and respectively 
*             $(D_KEYWORD uint) and $(D_KEYWORD ulong)
*  signed =   indicates if the type supports negative values, defaults to 
*             true; negative values are encoded using two's complement
* Usage:
* ---
*   alias uint128 = FixedInt!(128, false);
*   alias int96 = FixedInt!(96, true);
*   alias int128 = FixedInt!128;
*   alias uint1024 = FixedInt!(1024, false);
* 
*   uint128 a = 10;
*   int96 b = int96("12345678901234567890123456789");
* ---
* Members: 
*   $(LOCALMREF _FixedInt,digits) 
*   $(LOCALMREF _FixedInt,max) 
*   $(LOCALMREF _FixedInt,min) 
*   $(LOCALMREF _FixedInt,this)
*   $(LOCALMREF _FixedInt,to)
*   $(LOCALMREF _FixedInt,toBytes)
*   $(LOCALMREF _FixedInt,toChars)
*   $(LOCALMREF _FixedInt,toHash)
*   $(LOCALMREF _FixedInt,toRange)
*   $(LOCALMREF _FixedInt,toString)
* Initialization:
*   from $(LOCALMREF2 _FixedInt,this,integral, character or boolean), 
*        $(LOCALMREF2 _FixedInt,this.2,_FixedInt),
*        $(LOCALMREF2 _FixedInt,this.4,floating point),
*        $(LOCALMREF2 _FixedInt,this.3,string or character range)
*        $(LOCALMREF2 _FixedInt,this.5,bytes or byte range)
* Functions:
*   $(LOCALREF isPowerOf2) 
*   $(LOCALREF nextPow2) 
*   $(LOCALREF truncPow2)
* Traits:
*   $(LOCALREF isFixedInt) 
*   $(LOCALREF isSignedFixedInt) 
*   $(LOCALREF isUnsignedFixedInt)
*
* Operators:
*
*   $(TABLE
*       $(TR $(TH Operation) $(TH Expression) $(TH Left (A a)) $(TH Right (B b)) $(TH Result))
*       $(TR $(TD Assignment)
*            $(TD a = b) $(TD FixedInt)
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Positive)
*            $(TD +a) $(TD FixedInt) $(TD -)
*            $(TD FixedInt))
*       $(TR $(TD Negation (2-complement))
*            $(TD -a) $(TD FixedInt) $(TD -)
*            $(TD FixedInt))
*       $(TR $(TD Negation (logical)) 
*            $(TD ~a) $(TD FixedInt) $(TD -)
*            $(TD FixedInt))
*       $(TR $(TD Increment) 
*            $(TD ++a) $(TD FixedInt) $(TD -)
*            $(TD FixedInt))
*       $(TR $(TD Decrement) 
*            $(TD --a) $(TD FixedInt) $(TD -)
*            $(TD FixedInt))
*       $(TR $(TD Equality) 
*            $(TD a == b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD bool))
*       $(TR $(TD Order) 
*            $(TD a <> b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD bool))
*       $(TR $(TD Casting) 
*            $(TD cast(B)a)
*            $(TD FixedInt)     
*            $(TD integrals, floats, chars, bool or FixedInt)      
*            $(TD B))
*       $(TR $(TD Logical and) 
*            $(TD a & b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Logical or) 
*            $(TD a | b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Logical xor) 
*            $(TD a ^ b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Addition) 
*            $(TD a + b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Substraction) 
*            $(TD a - b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Multiplication) 
*            $(TD a * b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Division) 
*            $(TD a / b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Modulo) 
*            $(TD a % b) $(TD FixedInt) 
*            $(TD integrals, chars, bool or FixedInt)
*            $(TD FixedInt))
*       $(TR $(TD Shift left) 
*            $(TD a << b) $(TD FixedInt) 
*            $(TD integrals, chars or bool)
*            $(TD FixedInt))
*       $(TR $(TD Shift right) 
*            $(TD a >>> b) $(TD FixedInt) 
*            $(TD integrals, chars or bool)
*            $(TD FixedInt))
*       $(TR $(TD Arithmetic shift right) 
*            $(TD a >> b) $(TD FixedInt) 
*            $(TD integrals, chars or bool)
*            $(TD FixedInt))
*       $(TR $(TD Shift left) 
*            $(TD a << b) $(TD integrals, chars or bool) $(TD FixedInt)       
*            $(TD A))
*       $(TR $(TD Shift right) 
*            $(TD a >>> b) $(TD integrals, chars or bool) $(TD FixedInt) 
*            $(TD A))
*       $(TR $(TD Arithmetic shift right) 
*            $(TD a >> b) $(TD integrals, chars or bool) $(TD FixedInt) 
*            $(TD A))
*       $(TR $(TD Power) 
*            $(TD a ^^ b) $(TD FixedInt) 
*            $(TD integrals, chars or bool)
*            $(TD FixedInt))
*       $(TR $(TD Power) 
*            $(TD a ^^ b) $(TD integrals, chars or bool) $(TD FixedInt) 
*            $(TD A))
*   )
*
* Notes:
*   All operators are $(D_KEYWORD @safe pure nothrow @nogc);<br/>
*   D standard integer promotion rules are implemented;<br/>
*   Comparison and equality operators take into account the sign, therefore uint96.max will not be equal to -1 and comparing signed and unsigned operands is defined behaviour.<br/>
*/
struct FixedInt(uint bits, bool signed = true) if (bits >= 96 && bits % 32 == 0)
{
private:

    uint[bits / 32] data;
    
    enum ZERO_BITS = 0x0000_0000U;
    enum ONE_BITS  = 0xFFFF_FFFFU;
    enum SIGN_BITS = 0x8000_0000U;

    enum _bits = bits;
    enum _signed = signed;

    @safe pure nothrow @nogc 
    static auto getMin()
    {
        FixedInt!(bits, signed) x = void;
        static if (signed)
        {
            x.data[$ - 1] = SIGN_BITS;
            x.data[0 .. $ - 1] = ZERO_BITS;
        }
        else
            x.data[0 .. $] = ZERO_BITS;
        return x;
    }

    @safe pure nothrow @nogc 
    static auto getMax()
    {
        FixedInt!(bits, signed) x = void;
        static if (signed)
        {
            x.data[$ - 1] = ~SIGN_BITS;
            x.data[0 .. $ - 1] = ONE_BITS;
        }
        else
            x.data[0 .. $] = ONE_BITS;
        return x;
    }


    
    @safe pure nothrow @nogc
    size_t toBuffer(C)(C[] buffer, const uint radix, const bool uppercase = true) const if (isSomeChar!C)
    {
        if (radix == 10)
            return toBuffer10(buffer);
        if (radix == 16)
            return toBuffer16(buffer, uppercase);

        assert(radix >= 2 && radix <= 36);

        if (all(data, ZERO_BITS))
        {
            buffer[$ - 1] = '0';
            return buffer.length - 1;
        }

        FixedInt!(bits, false) v = this;
        size_t i = buffer.length - 1;
        
        if (ispow2(radix))
        {
            auto shift = ctz(radix);
            uint mask = (1U << shift) - 1;
            while (v)
            {
                auto r = v.data[0] & mask;
                buffer[i--] = digitToChar!C(r, uppercase);
                shr(v.data, shift);
            }
        }
        else
        {
            while (v)
            {
                auto r = divrem(v.data, radix);
                buffer[i--] = digitToChar!C(r, uppercase);
            }
        }
        return i + 1;
    }

    @safe pure nothrow @nogc
    size_t toBuffer16(C)(C[] buffer, const bool uppercase = true) const if (isSomeChar!C)
    {
        if (all(data, ZERO_BITS))
        {
            buffer[$ - 1] = '0';
            return buffer.length - 1;
        }

        size_t i = buffer.length - 1;

        auto x = data[0 .. used(data)];

        for (int j = 0; j < x.length; ++j)
        {
            uint v = x[j];
            if (j < x.length - 1)
            {
                buffer[i--] = digitToChar!C(v & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 4) & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 8) & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 12) & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 16) & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 20) & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 24) & 0xf, uppercase);
                buffer[i--] = digitToChar!C((v >> 28) & 0xf, uppercase);
            }
            else while (v)
            {
                buffer[i--] = digitToChar!C(v & 0xf, uppercase);
                v >>= 4;
            }
        }

        return i + 1;
    }

    @safe pure nothrow @nogc
    size_t toBuffer10(C)(C[] buffer, const bool uppercase = true) const if (isSomeChar!C)
    {
        if (all(data, ZERO_BITS))
        {
            buffer[$ - 1] = '0';
            return buffer.length - 1;
        }

        size_t i = buffer.length - 1;

        uint[bits / 32] x = data[];

        auto len = used(x);

        while (len > 1)
        {
            uint rem = divrem(x[0 .. len], 1_000_000_000U);
            uint digits = 0;
            while (rem)
            {
                buffer[i--] = digitToChar!C(rem % 10);
                rem /= 10;
                ++digits;
            }
            digits = 9 - digits;
            while (digits--)
                buffer[i--] = '0';
            if (x[len - 1] == 0)
                --len;
        }

        auto rem = x[0];
        while (rem)
        {
            buffer[i--] = digitToChar!C(rem % 10);
            rem /= 10;
        }

        return i + 1;
    }


    @safe pure nothrow @nogc
    bool fromString(S)(auto const ref S buffer, const uint radix, out bool overflow) if (isSomeString!S)
    {
        assert(radix >= 2 && radix <= 36);
        overflow = false;
        size_t i = 0;
        bool anyDigit = false;
        bool p2 = ispow2(radix);
        auto w = ctz(radix);
        uint width = 0;

        data[] = ZERO_BITS;

        while (i < buffer.length && (buffer[i] == '_' || buffer[i] == '0'))
        {
            if (!anyDigit && buffer[i] == '0')
                anyDigit = true;
            ++i;
        }

        while (i < buffer.length)
        {
            if (buffer[i] != '_')
            {
                auto r = charToDigit(buffer[i], radix);
                if (r < 0)
                    return false;
                anyDigit = true;
                if (p2)
                {
                    width += w;
                    if (width > bits)
                    {
                        overflow = true;
                        return false;
                    }
                    shl(data, w);
                    data[0] |= r;
                }
                else
                {
                    auto carry = mul(data, radix);
                    if (carry)
                    {
                        overflow = true;
                        return false;
                    }
                    carry = add(data, r);
                    if (carry)
                    {
                        overflow = true;
                        return false;
                    }
                }
                ++i;
            }
            else
                ++i;
        }

        return anyDigit;
    }

    @safe pure nothrow @nogc
    bool fromString10(S)(auto const ref S buffer, out bool overflow) if (isSomeString!S)
    {
        static immutable ulong[19] pow10 = 
            [10UL^^0, 10UL^^1, 10UL^^2, 10UL^^3, 10UL^^4, 10UL^^5, 10UL^^6, 10UL^^7, 10UL^^8, 10UL^^9,
             10UL^^10, 10UL^^11, 10UL^^12, 10UL^^13, 10UL^^14, 10UL^^15, 10UL^^16, 10UL^^17, 10UL^^18];
        data[] = ZERO_BITS;
        bool anyDigit;
        overflow = false;
        ptrdiff_t i = 0;
        while (i < buffer.length && (buffer[i] == '_' || buffer[i] == '0'))
        {
            if (!anyDigit && buffer[i] == '0')
                anyDigit = true;
            ++i;
        }
        
        
        ptrdiff_t j = buffer.length - 1;

        uint factor = 0;
        while (j >= i)
        {
            uint p = 0;
            ulong limb = 0;
            while (j >= i && p < pow10.length)
            {
                auto c = buffer[j--];
                auto r = c - '0';
                if (r >= 0 && r < 10)
                {
                    limb += r * pow10[p++];
                    anyDigit = true;
                }
                else if (c != '_')
                    return false;
            }
            ++factor;
            //limb1 * 10^0 + limb2 * 10^19 + limb3 * 10^38 + limb4 * 10^57 ...
            if (factor > 1)
            {
                uint[bits / 32 + 2] mulacc;
                uint[2] nineteen = [cast(uint)(10UL^^19), cast(uint)((10UL^^19) >>> 32)]; 
                uint[bits / 32] acc;
                mov(acc, limb);
                for (int k = 1; k < factor; ++k)
                {
                    mul(mulacc, acc, nineteen);
                    if (mulacc[$ - 1] || mulacc[$ - 2])
                    {
                        overflow = true;
                        return false;
                    }
                    acc[] = mulacc[0 .. acc.length];
                }
                auto carry = add(data, acc);
                if (carry)
                {
                    overflow = true;
                    return false;
                }
            }
            else
                mov(data, limb);

        }
        

        return anyDigit;
    }

    @safe pure nothrow @nogc
    bool fromString16(S)(auto const ref S buffer, out bool overflow) if (isSomeString!S)
    {
        enum int[8] shifts = [0, 4, 8, 12, 16, 20, 24, 28];
        data[] = ZERO_BITS;
        bool anyDigit;
        //overflow = false;
        ptrdiff_t i = 0;
        while (i < buffer.length && (buffer[i] == '_' || buffer[i] == '0'))
        {
            if (!anyDigit && buffer[i] == '0')
                anyDigit = true;
            ++i;
        }


        ptrdiff_t j = buffer.length - 1;

        uint k = 0;
        while (j >= i)
        {
            uint p = 0;
            uint limb = 0;
            while (j >= i && p < shifts.length)
            {
                auto c = buffer[j--];
                auto r = (c >= '0' && c <= '9') ? c - '0' : 
                         ((c >= 'A' && c <= 'F') ? c - 'A' + 10 : 
                         ((c >= 'a' && c <= 'f') ? c - 'a' + 10 : -1));
                if (r >= 0 && r <= 15)
                {
                    limb |= r << shifts[p++];
                    anyDigit = true;
                }
                else if (c != '_')
                    return false;
            }           
            data[k++] = limb;
            if (k >= data.length && j >= i)
            {
                overflow = true;
                return false;
            }
        }
        return anyDigit;
    }

    bool fromRange(R)(R range, const uint radix, out bool overflow) if (isInputRange!R && isSomeChar!(ElementType!R))
    {
        assert(radix >= 2 && radix <= 36);
        overflow = false;
        size_t i = 0;
        bool anyDigit = false;
        bool p2 = ispow2(radix);
        auto w = ctz(radix);
        uint width = 0;

        data[] = ZERO_BITS;
    
        while (!range.empty)
        {
			if (range.front != '0' && range.front != '_')
				break;
			anyDigit = range.front == '0';
            range.popFront();
        }

        while (!range.empty)
        {
            auto c = range.front;
            if (c != '_')
            {
                auto r = charToDigit(c, radix);
                if (r < 0)
                    return false;
                anyDigit = true;
                if (p2)
                {
                    width += w;
                    if (width > bits)
                    {
                        overflow = true;
                        return false;
                    }
                    shl(data, w);
                    data[0] |= r;
                }
                else
                {
                    auto carry = mul(data, radix);
                    if (carry)
                    {
                        overflow = true;
                        return false;
                    }
                    carry = add(data, r);
                    if (carry)
                    {
                        overflow = true;
                        return false;
                    }
                }
            }
            else
            {
                //skip '_'
            }
            range.popFront();
        }

        return anyDigit;
    }

    pure @safe nothrow @nogc
    T toFloat(T)() const if (isFloatingPoint!T)
    {
        auto usedx = used(data);
        if (usedx == 0)
            return 0.0;
        else if (usedx == 1)
            return cast(T)data[0];
        else if (usedx == 2)
        {
            ulong u = (cast(ulong)data[1]) << 32 | data[0];
            return cast(T)u;
        }
        else
        {
            static if (signed)
            {
                uint[bits / 32] num = data[];
                if (data[$ - 1] & SIGN_BITS)
                    neg(num);
                usedx = used(num);
                if (usedx == 1)
                    return data[$ - 1] & SIGN_BIT ? -cast(T)num[0] : cast(T)num[0];
                else if (usedx == 2)
                {
                    ulong u = (cast(ulong)data[1]) << 32 | data[0];
                    return data[$ - 1] & SIGN_BIT ? -cast(T)u : cast(T)u;
                }
            }
            else
                alias num = data;

            ulong mantissa = (cast(ulong)num[usedx - 1] << 32) | num[usedx - 2];

            exp = (usedx - 2) * 32;
            auto lz = clz(mantissa);
            if (lz)
            {
                mantissa <<= lz;
                mantissa |= num[usedx - 3] >> (32 - lz);
                exp -= lz;
            }

            static if (is(Unqual!T == float))
            {
                mantissa >>= 32;
                exp += 32;
                return fpack(signed && isNegative, exp, cast(uint)mantissa);
            }
            else static if (is(Unqual!T == real) && real.sizeof == 10)
                return rpack(signed && isNegative, exp, mantissa);
            else
                return dpack(signed && isNegative, exp, mantissa);
        }
    }

    @safe pure
    bool fromFloat(T)(T x, out bool underflow, out bool overflow, out bool inexact) if (isFloatingPoint!T)
    {
        overflow = false;
        underflow = false;
        inexact = false;

        static if (is(Unqual!T == float))
            uint mantissa;
        else
            ulong mantissa;

        int exp; 
        bool inf, nan;
        
        static if (is(Unqual!T == float))
            bool sign = funpack(x, exp, mantissa, inf, nan);
        else static if (is(Unqual!T == real) && real.mant_dig == 64)
            bool sign = runpack(x, exp, mantissa, inf, nan);
        else
            bool sign = dunpack(cast(double)x, exp, mantissa, inf, nan);

        if (nan)
        {
            mov(data, 0);
            return false;
        }

        if (inf)
        {
            data[] = sign ? min.data[] : max.data[];
            inexact = true;
            overflow = true;
            return false;
        }

        if (mantissa == 0)
        {
            data[] = 0;
            return true;
        }

        static if (!signed)
        {
            if (sign)
            {
                data[] = 0;
                overflow = true;
                inexact = true;
                return false;
            }
        }

        static if (is(Unqual!T == float))
        {
            if (exp < 0)
            {
                if (exp < -32)
                {
                    data[] = 0;
                    underflow = true;
                    inexact = true;
                    return false;
                }
                auto tz = ctz(mantissa);
                data[0] = mantissa >> -exp;
                if (tz < -exp)
                {
                    static if (signed)
                    {
                        if (sign)
                            neg(data);
                    }
                    inexact = true;
                    return false;
                }
            }
            else
            {
                data[0] = mantissa;
                auto availableBits = bits - 32 + clz(mantissa);
                static if (signed)
                    --availableBits;
                if (exp > availableBits)
                {
                    data[] = sign ? min.data[] : max.data[];
                    inexact = true;
                    overflow = true;
                    return false;
                }
                shl(data, exp);
            } 
        }
        else
        {
            if (exp < 0)
            {
                if (exp < -64)
                {
                    data[] = 0;
                    underflow = true;
                    inexact = true;
                    return false;
                }
                auto tz = ctz(mantissa);
                ulong m = mantissa >> -exp;
                data[0] = cast(uint)m;
                data[1] = cast(uint)(m >> 32);
                if (tz < -exp)
                {
                    static if (signed)
                    {
                        if (sign)
                            neg(data);
                    }
                    inexact = true;
                    return false;
                }
            }
            else
            {
                data[0] = cast(uint)mantissa;
                data[1] = cast(uint)(mantissa >> 32);
                auto availableBits = bits - 64 + clz(mantissa);
                static if (signed)
                    --availableBits;
                if (exp > availableBits)
                {
                    data[] = sign ? min.data[] : max.data[];
                    inexact = true;
                    overflow = true;
                    return false;
                }
                shl(data, exp);
            }
        }

        static if (signed)
        {
            if (sign)
                neg(data);
        }

        return true;
    }

    FixedInt!(bits, signed) round(const uint d) const
    {
        static if (!signed)
            alias x = this;
        else
            FixedInt!(bits, false) x = data[$ - 1] & SIGN_BITS ? -this : this;
        
        auto digs = digits;

        if (digs > d)
        {
            FixedInt!(bits, false) pow10 = FixedInt!(bits, false)(10) ^^ (digs - d);
            uint[bits / 32] rem = void;
            FixedInt!(bits, signed) q = void;
            divrem(q.data, rem, x.data, pow10.data);
            shr(pow10.data, 1);
            if (cmpuu(rem, pow10.data) >= 0)
                inc(q.data);
            static if (signed)
            {
                if (data[$ - 1] & SIGN_BITS)
                    neg(q.data);
            }
            return q;
        }
        else
            return this;
    }


public:
    ///minimum and maximum representable values
    enum min = getMin();
    ///ditto
    enum max = getMax();

    /**
    * Constructs a fixed size integer from a built in integral, character or 
    * boolean type.
    * Params:
    *  x = any integral, character, or boolean value.
    */
    @safe pure nothrow @nogc 
    this(T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {

        data[0] = cast(uint)x;

        static if (T.sizeof > 4)
        {
            data[1] = cast(uint)(x >> 32);
        }

        static if (isSomeSigned!T)
        {
            if (x < 0)
                data[T.sizeof > 4 ? 2 : 1 .. $] = ONE_BITS;
        }                   
    }

    ///
    unittest
    {
        assert(uint96(42) == 42);
        assert(int96(-10) == -10);
        assert(uint128('A') == 65);
        assert(int160(true) == 1);
    }

    /**
    * Constructs a fixed size integer from another one.
    * Params:
    *  x = any fixed size integer
    * Throws:
    *  $(PHOBOSREF conv,ConvOverflowException) if the specified value does not 
    *  fit in the current one.
    */
    @safe pure nothrow @nogc 
    this(T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        data[0 .. x.data.length] = x.data[];

        static if (T.sizeof < this.sizeof && T._signed)
        {
            if (x.data[$ - 1] & SIGN_BITS)
                data[x.data.length .. $] = ONE_BITS;
        }                   
    }

    ///ditto
    this(T)(auto const ref T x) if (isFixedInt!T && T.sizeof > this.sizeof)
    {
        data[] = x.data[0 .. data.length];
        bool overflow;
        static if (T._signed)
            overflow = !all(x.data[data.length .. $], x.data[$ - 1] & SIGN_BITS ? ONE_BITS: ZERO_BITS);
        else
            overflow = !all(x.data[data.length .. $], ZERO_BITS);
        
        if (overflow)
            throw new ConvOverflowException(format("The specified value '%s' does not fit in %d bits.", x, bits));                      
    }

    ///
    unittest
    {
        assert(uint128(uint96(42)) == 42);
        assert(int96(int128(-42)) == -42);
    }

    /** 
    * Constructs a fixed size integer from a string value or a range of input 
    * characters
    * Params:
    *  s = a string that contains decimal, hexadecimal, octal or binary digits 
    *      or any other digit if a radix is provided; 
    *  range = a character input range that contains decimal, hexadecimal, octal 
    *      or binary digits or any other digit if a radix is provided; 
    *  radix = a value between 2 and 36 representing the number base.
    * Throws:
    *  $(PHOBOSREF conv,ConvOverflowException) if the _value does not fit in 
    *  the current FixedInt type;<br/>
	*  $(PHOBOSREF conv,ConvOverflowException) if the _value is negative and the 
	*  current type is unsigned;<br/>
    *  $(PHOBOSREF conv, ConvException) if the specified string is empty or
    *  contains invalid characters;<br/>
    *  $(PHOBOSREF conv, ConvException) if the specified radix is outside the 
    *  interval [2; 36].
    * Notes:
    *   Strings starting with $(B 0x) or $(B 0X) will be interpreted as 
    *   hexadecimal;<br/>
    *   Strings starting with $(B 0b) or $(B 0B) will be interpreted as 
    *   binary;<br/>
    *   Strings starting with $(B 0o) or $(B 0O) will be interpreted as
    *   octal;<br/>
    *   String prefixes are accepted only if a radix is not provided;<br/>
    *   Strings without any prefix will be interpreted as decimal if a radix
    *   is not provided;<br/>
    *   $(B +/-) sign is accepted only for decimal input strings and if a 
    *   radix is not provided;<br/>
    *   Underscore characters are ignored.
    */
    @safe 
    this(S)(auto const ref S s) if (isSomeString!S)
    {
		bool success, isNegative, overflow, tenRadix;

		if (!s.length)
			throw new ConvException("The specified string is empty");

		if (s[0] == '+')
		{
			if (s.length <= 2)
				throw new ConvException("Expecting at least one digit");
			tenRadix = true;
			success = fromString10(s[1 .. $], overflow);
		}
		else if (s[0] == '-')
		{
			static if (!signed)
			{
				throw new ConvOverflowException("Negative values are not accepted for unsigned fixed integers");
			}
			else
			{
				isNegative = true;
				if (s.length <= 2)
					throw new ConvException("Expecting at least one digit");
				tenRadix = true;
				success = fromString10(s[1 .. $], overflow);
			}

		}
		else if (s[0] != '0')
		{
			tenRadix = true;
			success = fromString10(s, overflow);		
		}
		else
		{
			if (s.length == 1)
				success = true;
			else
			{
				switch (s[1])
				{
					case 'x':
					case 'X':
						success = fromString16(s[2 .. $], overflow);
						break;
					case 'o':
					case 'O':
						success = fromString(s[2 .. $], 8, overflow);
						break;
					case 'b':
					case 'B':
						success = fromString(s[2 .. $], 2, overflow);
						break;
					default:
						tenRadix = true;
						success = fromString10(s[1 .. $], overflow);
						break;
				}
			}
		}
		

        //detect base 10 overflow
		static if (signed)
		{
			if (success && tenRadix)
			{
				if (isNegative)
					neg(data);

				bool n = cast(bool)(data[$ - 1] & SIGN_BITS);
				if (isNegative != n)
				{
					overflow = true;
					success = false;
				}
			}
		}
  

        if (overflow)
            throw new ConvOverflowException(format("The specified value '%s' does not fit in %d bits.", s, bits));
        else if (!success)
            throw new ConvException(format("The specified value '%s' cannot be parsed", s));
    }

    ///ditto
    @safe 
    this(S)(auto const ref S s, const uint radix) if (isSomeString!S)
    {
        if (radix < 2 || radix > 36)
            throw new ConvException(format("The specified radix (%d) is not supported. Use a value between %d and %d.", radix, 2, 36));

        bool success, overflow;

        switch(radix)
		{
			case 10:
				success = fromString10(s, overflow);
				break;
			case 16:
				success = fromString16(s, overflow);
				break;
			default:
				success = fromString(s, radix, overflow);
				break;
		}

		if (radix == 10 && (data[$ - 1] & SIGN_BITS))
		{
			overflow = true;
			success = false;
		}

        if (!success)
        {
            if (overflow)
                throw new ConvOverflowException(format("The specified value '%s' represented as base-%d does not fit in %d bits.", s, radix, bits));
            else
                throw new ConvException(format("The specified value '%s' cannot be parsed in base-%d", s, radix));
        }
    }

    ///ditto
    this(R)(R range) if (isInputRange!R && isSomeChar!(ElementType!R) && !isSomeString!R)
    {
		bool success, isNegative, overflow, tenRadix;

		if (range.empty)
			throw new ConvException("The specified range is empty");

		if (range.front == '+')
		{
			range.popFront();
			if (range.empty)
				throw new ConvException("Expecting at least one digit");
			tenRadix = true;
			success = fromRange(range, 10, overflow);
		}
		else if (range.front == '-')
		{
			static if (!signed)
			{
				throw new ConvOverflowException("Negative values are not accepted for unsigned fixed integers");
			}
			else
			{
				range.popFront();
				isNegative = true;
				if (range.empty)
					throw new ConvException("Expecting at least one digit");
				tenRadix = true;
				success = fromRange(range, 10, overflow);
			}

		}
		else if (range.front != '0')
		{
			tenRadix = true;
			success = fromRange(range, 10, overflow);		
		}
		else
		{
			range.popFront();
			if (range.empty)
				success = true;
			else
			{
				auto c = range.front();
				switch (c)
				{
					case 'x':
					case 'X':
						range.popFront();
						success = fromRange(range, 16, overflow);
						break;
					case 'o':
					case 'O':
						range.popFront();
						success = fromRange(range, 8, overflow);
						break;
					case 'b':
					case 'B':
						range.popFront();
						success = fromRange(range, 2, overflow);
						break;
					default:
						tenRadix = true;
						success = fromRange(range, 10, overflow);
						break;
				}
			}
		}


		//detect base 10 overflow
		static if (signed)
		{
			if (success && tenRadix)
			{
				if (isNegative)
					neg(data);

				bool n = cast(bool)(data[$ - 1] & SIGN_BITS);
				if (isNegative != n)
				{
					overflow = true;
					success = false;
				}
			}
		}

		if (overflow)
			throw new ConvOverflowException(format("The specified value does not fit in %d bits.", bits));
		else if (!success)
			throw new ConvException("The specified value cannot be parsed");
		
    }

    ///ditto
    this(R)(R range, const uint radix) if (isInputRange!R && isSomeChar!(ElementType!R) && !isSomeString!R)
    {
        if (radix < 2 || radix > 36)
            throw new ConvException(format("The specified radix (%d) is not supported. Use a value between %d and %d.", radix, 2, 36));

        bool success, overflow;

        success = fromRange(range, radix, overflow);
		if (radix == 10 && (data[$ - 1] & SIGN_BITS))
		{
			overflow = true;
			success = false;
		}
        if (!success)
        {
            if (overflow)
                throw new ConvOverflowException(format("The specified value represented as base-%d does not fit in %d bits.", radix, bits));
            else
                throw new ConvException(format("The specified value cannot be parsed in base-%d", radix));
        }
    }

    ///
    unittest
    {
        assert(uint128("123") == 123);
        assert(uint128("0xFFFFFFFF") == 0xFFFFFFFF);
        assert(uint128("0b10101010") == 0b10101010);
        assert(uint128("0o666") == 0x1b6);
        assert(int128("-42") == -42);
        assert(int128("+42") == 42);

        assert(uint128("9999", 10) == 9999);
        assert(uint128("AAAA", 16) == 0xAAAA);
        assert(uint128("1111", 2) == 0b1111);

        assert(uint96("123_456_789") == 123456789);
        assert(int96("0xABCD_EF00") == 0xABCDEF00);
    }

    /**
    * Constructs a fixed size integer from a floating point value
    * Params:
    *  x = any floating point value.
    * Throws:
    *  $(PHOBOSREF conv,ConvException) if the floating point value is NaN or 
    *  cannot be represented exactly as a FixedInt ;<br/>
    *  $(PHOBOSREF conv,ConvOverflowException) if the floating point value is 
    *  not finite, it does not fit in the current fixed size integer, 
    *  or is underflowing towards 0.
    * Notes:
    *  Only 80-bit $(D_KEYWORD real) type is supported. Other real types are 
    *  converted to $(D_KEYWORD double) before the construction;<br/>
    */
    @safe 
    this(F)(auto const ref F x) if (isFloatingPoint!F)
    {
        bool inexact, underflow, overflow;
        
        if (!fromFloat(x, underflow, overflow, inexact))
        {
            if (overflow)
                throw new ConvOverflowException(format("The specified value '%f' does not fit in %d bits.", x, bits));
            else if (underflow)
                throw new ConvOverflowException(format("The specified value '%f' is too small to be represented.", x));
            else if (inexact)
                throw new ConvOverflowException(format("The specified value '%f' cannot be represented exactly in %d bits.", x, bits));
            else
                throw new ConvException(format("The specified value '%f' cannot be represented as integral.", x));
        }

    }

    

    ///
    unittest
    {
        assert(uint128(0.0) == 0);
        assert(uint128(129.0) == 129);
        assert(uint128(1.23E+3) == 1230);
    }
    
    /**
    * Constructs a fixed size integer using an _array or _range of any type
    * Params:
    *  array = an _array of data
    *  range = a data _range
    * Throws:
    *  $(PHOBOSREF conv,ConvOverflowException) if the specified _array or _range
    *  does not fit in the current fixed size integer
    * Notes:
    *  The most significant bit of the _array or _range data will set the sign.<br/>
	*  Character ranges or strings are interpreted as decimal numbers, not as raw data. 
	*  Using a character _range or string will call one of the $(LOCALMREF2 _FixedInt,this.3,string constructors)
    */
	@trusted pure
	this(A)(auto const ref A array) if (isArray!A && !isSomeString!A)
	{
		alias E = Unqual!(typeof(A.init[0]));

		enum elementSize = E.sizeof;
		enum bytes = array.length * elementSize;
		enum thisbytes = data.length * 4;
		if (bytes > thisBytes)
			throw new ConvOverflowException(format("The specified array does not fit in %d bits.", bits));
		memcpy(array.ptr, data.ptr, bytes);
	}

    ///ditto
    @trusted pure
    this(R)(ref R range) if (isInputRange!R && !isArray!R && !isSomeChar!(ElementType!R))
    {
		alias E = Unqual!(ElementType!R);
		enum elementSize = E.sizeof;
		enum bufferSize = data.length * 4 / elementSize;

		E[bufferSize] buffer = void;

	    size_t i;

		while (!range.empty && i < buffer.length)
		{
			buffer[i++] = range.front;
			range.popFront();
		}

		memcpy(buffer.ptr, data.ptr, i * elementSize);
		

		if (!range.empty)
		    throw new ConvOverflowException(format("The specified range does not fit in %d bits.", bits));
    }

    ///
    unittest
    {
		//assert(uint128([12]) == 12);
		//assert(uint128([0xAA, 0xBB]) == 0xBBAA);
    }


    @safe pure nothrow @nogc 
    auto ref opAssign(T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeUnsigned!T)
            mov(data, x);
        else
            movs(data, x);
        return this;
    }

    @safe pure nothrow @nogc 
    auto ref opAssign(T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        static if (isUnsignedFixedInt!T)
            mov(data, x.data);
        else
            movs(data, x.data);
        return this;
    }

    @safe pure nothrow @nogc 
    bool opEquals(T)(auto const ref T x) const if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool)) 
    {
        static if (signed)
        {
            static if (isSomeSigned!T)
                return equss(data, x);
            else
                return equsu(data, x);
        }
        else
        {
            static if (isSomeUnsigned!T)
                return equuu(data, x);
            else
                return equus(data, x);
        }          
    }

    @safe pure nothrow @nogc 
    bool opEquals(T)(auto const ref T x) const if (isFixedInt!T) 
    {
        static if (signed)
        {
            static if (T._signed)
                return equss(data, x.data);
            else
                return equsu(data, x.data);
        }
        else
        {
            static if (!T._signed)
                return equuu(data, x.data);
            else
                return equus(data, x.data);
        }          
    }

    @safe pure nothrow @nogc 
    int opCmp(T)(auto const ref T x) const if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool)) 
    {
        static if (signed)
        {
            static if (isSomeSigned!T)
                return cmpss(data, x);
            else
                return cmpsu(data, x);
        }
        else
        {
            static if (isSomeUnsigned!T)
                return cmpuu(data, x);
            else
                return cmpus(data, x);
        }          
    }

    @safe pure nothrow @nogc 
    int opCmp(T)(auto const ref T x) const if (isFixedInt!T) 
    {
        static if (signed)
        {
            static if (T._signed)
                return cmpss(data, x.data);
            else
                return cmpsu(data, x.data);
        }
        else
        {
            static if (!T._signed)
                return cmpuu(data, x.data);
            else
                return cmpus(data, x.data);
        }          
    }

    @safe pure nothrow @nogc 
    T opCast(T)() const if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (is(Unqual!T == bool))
            return !all(data, ZERO_BITS);
        else static if (T.sizeof <= 4)
            return cast(Unqual!T)data[0];
        else
            return cast(Unqual!T)data[1] << 32 | data[0];  
    }

    @safe pure nothrow @nogc 
    T opCast(T)() const if (isFixedInt!T)
    {
        static if (T.sizeof == this.sizeof)
            return T(this);
        else static if (T.sizeof < this.sizeof)
        {
            Unqual!T x = void;
            x.data[0 .. $] = data[0 .. x.data.length];
            return x;
        }
        else
            return Unqual!T(this);
    }

    @safe pure nothrow @nogc 
    T opCast(T)() const if (isFloatingPoint!T)
    {
        return toFloat!T();
    }

    @safe pure nothrow @nogc
    auto opUnary(string op : "+")() const
    {
        return this;
    }

    @safe pure nothrow @nogc
    auto opUnary(string op : "-")() const
    {
        FixedInt!(bits, signed) x = this;
        neg(x.data);
        return x;
    }

    @safe pure nothrow @nogc
    auto opUnary(string op : "~")() const
    {
        FixedInt!(bits, signed) x = this;
        not(x.data);
        return x;
    }

    @safe pure nothrow @nogc
    auto ref opUnary(string op : "++")()
    {
        inc(data);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opUnary(string op : "--")()
    {
        dec(data);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "|", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeSigned!T)
            ors(data, x);
        else
            or(data, x);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "&", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeSigned!T)
            ands(data, x);
        else
            and(data, x);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "^", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeSigned!T)
            xors(data, x);
        else
            xor(data, x);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "|", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        static if (isSomeSigned!T)
            ors(data, x.data);
        else
            or(data, x.data);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "&", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        static if (isSomeSigned!T)
            ands(data, x.data);
        else
            and(data, x.data);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "^", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        static if (isSomeSigned!T)
            xors(data, x.data);
        else
            xor(data, x.data);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "<<", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        auto shift = cast(uint)(x % bits);
        if (shift > 0)
            shl(data, shift);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : ">>>", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        auto shift = cast(uint)(x % bits);
        if (shift > 0)
            shr(data, shift);
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : ">>", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        auto shift = cast(uint)(x % bits);
        if (shift > 0)
        {
            static if (signed)
                sahr(data, shift);
            else
                shr(data, shift);
        }
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "+", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeUnsigned!T)
            add(data, x);
        else
        {
            if (x >= 0)
                add(data, x);
            else
            {
                Unsigned!T xx = -x;
                sub(data, xx);
            }
        }
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "+", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        static if (!T._signed)
            add(data, x.data);
        else
        {
            if ((x.data[$ - 1] & SIGN_BITS) == 0)
                add(data, x.data);
            else
            {
                uint[T._bits / 32] ndata = x.data[];
                neg(ndata);
                sub(data, ndata);
            }
        }
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "-", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeUnsigned!T)
            sub(data, x);
        else
        {
            if (x >= 0)
                sub(data, x);
            else
            {
                Unsigned!T xx = -x;
                add(data, xx);
            }
        }
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "-", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        static if (!T._signed)
            sub(data, x.data);
        else
        {
            if ((x.data[$ - 1] & SIGN_BITS) == 0)
                sub(data, x.data);
            else
            {
                uint[T._bits / 32] ndata = x.data[];
                neg(ndata);
                add(data, ndata);
            }
        }
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "*", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        bool st = signed && (data[$ - 1] & SIGN_BITS);
        bool sx = isSomeSigned!T && x < 0;

        if (st)
            neg(data);

        auto xx = sx ? -x : x;

        static if (T.sizeof <= 4)
            mul(data, cast(uint)xx);
        else
        {
            uint[bits / 32 + 2] ret = void;
            uint[2] xdata = [cast(uint)xx, cast(uint)(xx >>> 32)];
            mul(ret, data, xdata);
            data[] = ret[0 .. data.length];
        }

        if (st != sx)
            neg(data);

        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "*", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        bool st = signed && (data[$ - 1] & SIGN_BITS);
        bool sx = T._signed && (x.data[$ - 1] & SIGN_BITS);

        if (st)
            neg(data);

        auto xx = sx ? -x : x;

        uint[(bits + T._bits) / 32] ret;
        
        mul(ret, data, xx.data);
        data[] = ret[0 .. data.length];

        if (st != sx)
            neg(data);

        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "/", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        bool st = signed && (data[$ - 1] & SIGN_BITS);
        bool sx = isSomeSigned!T && x < 0;

        if (st)
            neg(data);

        auto xx = sx ? -x : x;

        static if (T.sizeof <= 4)
            divrem(data, cast(uint)xx);
        else
        {
            uint[bits / 32] quo = void, rem = void;
            uint[2] xdata = [cast(uint)xx, cast(uint)(xx >>> 32)];
            divrem(quo, rem, data, xdata);
            data[] = quo[0 .. data.length];
        }

        if (st != sx)
            neg(data);

        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "/", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        bool st = signed && (data[$ - 1] & SIGN_BITS);
        bool sx = T._signed && (x.data[$ - 1] & SIGN_BITS);

        if (st)
            neg(data);

        auto xx = sx ? -x : x;

        uint[bits / 32] quo = void, rem = void;
        divrem(quo, rem, data, xx.data);
        data[] = quo[0 .. data.length];

        if (st != sx)
            neg(data);

        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "%", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        bool st = signed && (data[$ - 1] & SIGN_BITS);
        bool sx = isSomeSigned!T && x < 0;

        if (st)
            neg(data);

        auto xx = sx ? -x : x;

        static if (T.sizeof <= 4)
            mov(data, rem(data, cast(uint)xx));
        else
        {
            uint[bits / 32] rm = void;
            uint[2] xdata = [cast(uint)xx, cast(uint)(xx >>> 32)];
            rem(rm, data, xdata);
            data[] = rm[0 .. data.length];
        }

        if (st)
            neg(data);

        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "%", T)(auto const ref T x) if (isFixedInt!T && T.sizeof <= this.sizeof)
    {
        bool st = signed && (data[$ - 1] & SIGN_BITS);
        bool sx = T._signed && (x.data[$ - 1] & SIGN_BITS);

        if (st)
            neg(data);

        auto xx = sx ? -x : x;

        uint[bits / 32] rm = void;
        rem(rm, data, xx.data);
        data[] = rm[0 .. data.length];

        if (st)
            neg(data);

        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "^^", T)(auto const ref T x) if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (isSomeSigned!T)
        {
            if (x < 0)
                data[0] /= 0;
        }

        switch(x)
        {
            case 0:
                mov(data, 1);
                break;
            case 1:
                break;
            case 2:
                uint[bits / 16] p;
                squ(p, data);
                data[] = p[0 .. data.length];
                break;
            default:
                Unqual!T exp = x;
                FixedInt!(bits, signed) ret = 1;
                FixedInt!(bits, signed) base = this;
                while (exp && !all(ret.data, ZERO_BITS))
                {
                    if (exp & 1)
                        ret *= base;
                    exp >>>= 1;
                    base *= base;
                }
                this.data[] = ret.data[];
                break;
        }
        return this;
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op : "^^", T)(auto const ref T x) if (isFixedInt!T)
    {
        static if (T._signed)
        {
            if (x[$ - 1] & SIGN_BITS)
                data[0] / 0;
        }

        auto usedx = used(x);

        if (usedx == 0)
            mov(data, 1);
        else if (usedx == 1 && x[0] == 1)
        {}
        else if (usedx == 1 && x[0] == 2)
        {
            uint[bits / 16] p;
            squ(p, this);
            mov(data, p[0 .. x.length]);
        }
        else
        {
            Unqual!T exp = x;
            FixedInt!(bits, signed) ret = 1;
            FixedInt!(bits, signed) base = this;
            while (!all(exp, ZERO_BITS) && !all(ret, ZERO_BITS))
            {
                if (exp.data[0] & 1)
                {
                    ret *= this;
                }
                shr(exp, 1);
                base *= base;
            }
        }
    }

    @safe pure nothrow @nogc
    auto ref opOpAssign(string op, T)(auto const ref T x) if (isFixedInt!T && (op == ">>" || op == ">>>" || op == "<<"))
    {
        return opOpAssign(op, T)(x.data[0]);
    }

    @safe pure nothrow @nogc
    auto opBinary(string op, T)(auto const ref T x) const
        if ((isIntegral!T || isSomeChar!T || is(Unqual!T == bool)) &&
            (op == "|" || op == "&" || op == "^" || op == "+" || op == "-" || op == "*" || op == "/" || op == "%" || op == "^^"))
    {
        static if (isSomeSigned!T || signed)
            FixedInt!(bits, true) r = this;
        else
            FixedInt!(bits, false) r = this;
        mixin("r " ~ op ~ "= x;");
        return r;
    }

    @safe pure nothrow @nogc
    auto opBinaryRight(string op, T)(auto const ref T x) const
        if ((isIntegral!T || isSomeChar!T || is(Unqual!T == bool)) &&
            (op == "|" || op == "&" || op == "^" || op == "+" || op == "*" || op == "-" || op == "/" || op == "%"))
    {
        static if (isSomeSigned!T || signed)
            FixedInt!(bits, true) r = x;
        else
            FixedInt!(bits, false) r = x;
        mixin("r " ~ op ~ "= this;");
        return r;
    }

    @safe pure nothrow @nogc
    auto opBinary(string op, T)(auto const ref T x) const
        if ((isFixedInt!T) &&
            (op == "|" || op == "&" || op == "^" || op == "+" || op == "-" || op == "*" || op == "/" || op == "%"))
    {
        enum sgn = isSomeSigned!T || signed;
        
        static if (T.sizeof <= this.sizeof)
        {
            FixedInt!(bits, sgn) r = this;
            mixin("r " ~ op ~ "= x;");
        }
        else
        {
            FixedInt!(T._bits, sgn) r = x;
            mixin("r " ~ op ~ "= this;");
        }
        return r;
    }

    @safe pure nothrow @nogc
    auto opBinary(string op, T)(auto const ref T x) const
        if ((isIntegral!T || isSomeChar!T || is(Unqual!T == bool) || isFixedInt!T) &&
            (op == ">>" || op == ">>>" || op == "<<"))
    {
        FixedInt!(bits, signed) r = this;
        mixin("r " ~ op ~ "= x;");
        return r;
    }

    @safe pure nothrow @nogc
    auto opBinaryRight(string op, T)(auto const ref T x) const
        if ((isIntegral!T || isSomeChar!T || is(Unqual!T == bool)) &&
            (op == ">>" || op == ">>>" || op == "<<"))
    {
        FixedInt!(bits, signed) r = this;
        mixin("x " ~ op ~ "= data[0];");
        return r;
    }

    @safe pure nothrow @nogc
    auto opBinaryRight(string op: "^^", T)(auto const ref T x) const
        if (isIntegral!T || isSomeChar!T || is(Unqual!T == bool))
    {
        static if (signed)
        {
            if (data[$ - 1] & SIGN_BITS)
                data[0] / 0;
        }

        auto usedx = used(x);

        if (usedx == 0)
            return cast(Unqual!T)1;
        else if (usedx == 1 && x[0] == 1)
        {}
        else if (usedx == 1 && x[0] == 2)
        {
           return cast(Unqual!T)(x * x);
        }
        else
        {
            FixedInt!(bits, signed) exp = this;
            auto ret = cast(Unqual!T)1;
            auto base = cast(Unqual!T)x;
            while (!all(exp, ZERO_BITS) && ret)
            {
                if (exp.data[0] & 1)
                {
                    ret *= x;
                }
                shr(exp, 1);
                base *= base;
            }
        }

    }

    /**
    * Calculates a hash key for the current FixedInt value
    * Returns: a unique hash value
    * Notes:
    *   This function is not intended to be used directly, but it's
    *   used internally by associative arrays.
    */
    @safe pure nothrow @nogc
    size_t toHash() const
    {
        static if (is(size_t == uint))
            return hash(data);
        else
            return (cast(ulong)hash(data[0 .. data.length / 2]) << 32) |
                               hash(data[data.length / 2 .. $]);
    }

    ///
    unittest
    {
        string[int96] dictionary;
        dictionary[int96(0)] = "zero";
        dictionary[int96(10)] = "ten";
        
        assert(dictionary[int96(0)] == "zero");
        assert(dictionary[int96(10)] == "ten");
    }

    /**
    * Converts the current FixedInt value to its default decimal 
    * string representation
    * Returns:
    *   A base-10 representation of the current FixedInt value  
    */
    @safe pure nothrow
    string toString() const
    {
        char[bits / 3 + 1] buffer;

        static if (signed)
        {
            bool isNegative = cast(bool)(data[$ - 1] & SIGN_BITS);
            auto len = isNegative ? (-this).toBuffer(buffer, 10): toBuffer(buffer, 10);
        }
        else
            auto len = toBuffer(buffer, 10, false);

        static if (signed)
        {
            if (isNegative)
                buffer[--len] = '-';
        }
        return buffer[len .. $].idup();
    }

    ///
    unittest
    {
        assert(uint96(123).toString() == "123");
        assert(int128(-25).toString() == "-25");
    }

    /**
    * Converts the current FixedInt value to its a string 
    * representation using the specified format
    * Params:
    *   sink = a delegate for accepting custom segments of the 
    *   formatted string.
    *   f = a format string specifying the output format.
    * Throws:
    *   $(PHOBOSREF format,FormatException) if the format specifier
    *   is not supported.
    * Notes:
    *   This function is not supposed to be used directly, but it's used 
    *   internally by the standard library $(PHOBOSREF format,format) or 
    *   $(PHOBOSREF stdio,writef). <br/>
    *   Supported format specifiers:<ul>
    *   <li>$(B %d) - signed decimal</li>
    *   <li>$(B %i) - signed decimal</li>
    *   <li>$(B %u) - unsigned decimal</li>
    *   <li>$(B %x) - unsigned hexadecimal (lowercase)</li>
    *   <li>$(B %X) - unsigned hexadecimal (uppercase)</li>
    *   <li>$(B %o) - unsigned octal</li>
    *   <li>$(B %b) - unsigned binary</li>
    *   <li>$(B %s) - default string representation</li>
    *   </ul>
    */
    void toString(C)(scope void delegate(const(C)[]) sink, ref FormatSpec!char f) const if (isSomeChar!C)
    {
        bool hasSign, outputSign;
        bool skipSign;
        size_t r;
        Unqual!C[bits / 2] buffer; //enough for binary
        if (f.spec == 'x' || f.spec == 'X')
        {
            r = toBuffer16(buffer, f.spec == 'X');
            skipSign = true;
        }
        else if (f.spec == 'o')
        {
            r = toBuffer(buffer, 8, false);
            skipSign = true;
        }
        else if (f.spec == 'b')
        {
            r = toBuffer(buffer, 2, false);
            skipSign = true;
        }
        else if (f.spec == 'd' || f.spec == 'i' || f.spec == 'u' || f.spec == 's')
        {
            hasSign = f.spec != 'u' && signed && (data[$ - 1] & SIGN_BITS);
            FixedInt!(bits, false) num = f.spec == 'u' ? this : (hasSign ? -this : this);
            r = num.toBuffer(buffer, 10);
        }
        else
            throw new FormatException(format("Unsupported format specifier: '%s'", f.spec));

        int w = f.width;
        w -= (buffer.length - r);

        outputSign = (hasSign || f.flSpace || f.flPlus) && !skipSign;
        if (outputSign)
            --w;

        if (!f.flZero && !f.flDash && w > 0)
        {
            while (w--)
                sink(" ");
        }

        if (outputSign)
        {
            if (hasSign)
                sink("-");
            else if (f.flPlus)
                sink("+");
            else
                sink(" ");
        }

        if (f.flZero && !f.flDash && w > 0)
        {
            while (w--)
                sink("0");
        }

        sink(buffer[r .. $]);

        if (f.flDash && w > 0)
        {
            while(w--)
                sink(" ");
        }
    }

    ///
    unittest
    {
        import std.format;
        assert(format("%d in hex is %x or in octal is %o", 
                      uint96(123), int96(123), uint128(123)) ==
               "123 in hex is 7b or in octal is 173");
    }

    /**
    * Converts the current FixedInt value to its custom base representation
    * Params:
    *   radix = a base used to convert;
    *   lettercase = casing used if radix is greater than 10.
    * Throws:
    *  $(PHOBOSREF conv, ConvException) if the specified radix is outside the 
    *  interval [2; 36].  
    */
    @safe
    S to(S)(const uint radix = 10, const LetterCase lettercase = LetterCase.upper) const if (isSomeString!S)
    {
        if (radix < 2 || radix > 36)
            throw new ConvException(format("The specified radix (%d) is not supported. Use a value between %d and %d.", radix, 2, 36));

        alias C = Unqual!(typeof(S.init[0]));

        C[bits] buffer;
        static if (signed)
        {
            auto r = data[$ - 1] & SIGN_BITS ? (-this).toBuffer(buffer, radix, lettercase == LetterCase.upper) :
                toBuffer(buffer, radix, lettercase == LetterCase.upper);
        }
        else
            auto r = toBuffer(buffer, radix, lettercase == LetterCase.upper);

        static if (signed)
        {
            if (data[$ - 1] & SIGN_BITS)
                buffer[--r] = '-';
        }

        return buffer[r .. $].dup();
    }

    ///
    unittest
    {
        assert(uint96(123).to!string(10) == "123");
        assert(uint96(123).to!string(16, LetterCase.lower) == "7b");
        assert(uint96(123).to!string(16, LetterCase.upper) == "7B");
        assert(uint96(123).to!string(36) == "3F");
    }

    /** 
    * Converts the current fixed size integer _to its equivalent character range representation 
    * using the specified radix
    * Params:
    *   radix = a _radix between 2 and 36 used _to convert the input _value.
    *   letterCase = choose between character case for radixes greater than 10.
    * Returns:
    *   A range of characters representing of the current fixed size integer.
    * Notes:
    *   Negative values are prefixed with minus sign(-) only if radix is 10.
    */
    @safe pure nothrow @nogc
    auto toChars(uint radix = 10, C = char, LetterCase letterCase = LetterCase.upper)() if (isSomeChar!C)
    {
        static assert(radix >= 2 && radix <= 36);
        BufferedRange!(C, BUFFER_SIZE) range = void;

        static if (radix >= 32)
            enum BUFFER_SIZE = bits / 5;
        else static if (radix >= 16)
            enum BUFFER_SIZE = bits / 4;
        else static if (radix == 10)
            enum BUFFER_SIZE = bits / 3 + 1;
        else static if (radix >= 8)
            enum BUFFER_SIZE = bits / 3;
        else static if (radix >= 4)
            enum BUFFER_SIZE = bits / 2;
        else
            enum BUFFER_SIZE = bits;

        static if (radix == 10)
        {
            static if (signed)
            {
                if (data[$ - 1] & SIGN_BITS)
                {
                    FixedInt!(bits, false) v = -this;
                    range.lo = v.toBuffer(range.buffer, radix);
                    range.buffer[--range.lo] = '-';
                }
                else
                    range.lo = toBuffer(range.buffer, radix);
            }
            else
                range.lo = toBuffer(range.buffer, radix);
        }
        else
            range.lo = value.toBuffer(range.buffer, radix, letterCase = LetterCase.upper);

        range.hi = BUFFER_SIZE - 1;
        return range;
    }


    /** 
    * Converts the current fixed size integer _to an array or range of byte data
    * Returns:
    *   A byte array or a range of bytes as the internal representation of the 
    *   current fixed size integer.
    */
    @safe pure nothrow
    ubyte[] toBytes() const
    {
        return cast(ubyte[])(data.dup);
    }

    ///ditto
    @safe pure nothrow @nogc
    auto toRange() const
    {
        static struct Result
        {
            FixedInt!(bits, signed) d;
            ptrdiff_t index;
            int shift;
            @property bool empty() { return index < 0 || index >= d.data.length; }
            @property ubyte front() { return cast(ubyte)(d.data[index] >>> shift); }
            void popFront() { shift += 8; if (shift == 32) { shift = 0; ++index; } }
        }
        auto ret = Result();
        ret.d = this;
        return ret;
    }

    ///
    unittest
    {
        //assert(uint96(0xAABB).toBytes() == [0xBB, 0xAA]);
    }


    /**
    * Calculates the number of decimal _digits
    * Returns: 
    *   Number of decimal _digits for the current value or 0 for a zero value.
    */
    @safe pure nothrow @nogc
    @property uint digits() const
    {
        static if (!signed)
        {
            alias x = this;
        }
        else
        {
            FixedInt!(bits, false) x = (data[$ - 1] & SIGN_BITS) ? -this : this;
        }

        auto usedbits = bits - clz(x.data);
        return cast(uint)(floor(usedbits * log(2) / log(10)));
    }


    ///
    unittest
    {
		//assert(uint96(123).digits == 3);
		//assert(int128(-12345).digits == 5);
		//assert(uint128.max.digits == 38);
    }
    
}
/**
* Check whether a number is a power of two.
* Params:
*  x = a fixed size integer
* Returns:
*   true x that is a power of two, otherwise false. Zero values are not considered powers of 2.
*/
@safe pure nothrow @nogc
bool isPowerOf2(F)(auto const ref F x) if (isFixedInt!F)
{
    static if (isUnsignedFixedInt!F)
        return ispow2(x.data);
    else
        return (x.data[$ - 1] & SIGN_BITS) && ispow2(x.data);
}

/**
* Gives the next power of two.
* Params:
*  x = a fixed size integer
* Returns:
*   The next value after x that is a power of two, zero if x is 0.
*/
@safe pure nothrow @nogc
auto nextPow2(F)(auto const ref F x) if (isFixedInt!F)
{
    if (all(x.data, ZERO_BITS))
        return 0;

    static if (isUnsignedFixedInt!F)
    {
        auto shift = clz(x) + 1;
        return shift >= F.sizeof * 4 ? F(0) : F(1) << shift;
    }
    else
    {
        bool negative = cast(bool)(data[$ - 1] & SIGN_BITS);
        FixedInt!(bits, false) x = negative ? -x : x;
        auto shift = clz(x) + 1;
        if (shift >= F.sizeof * 4)
            return F(0);
        else
        {
            x <<= (clz(x) + 1);
            return F(negative ? x : -x);
        }
    }
}

/**
* Gives the previous power of two.
* Params:
*  x = a fixed size integer
* Returns:
*   The previous value before x that is a power of two, x itself if it's already a power of two, zero if x is 0.
*/
@safe pure nothrow @nogc
auto truncPow2(F)(auto const ref F x) if (isFixedInt!F)
{
    if (all(x.data, ZERO_BITS))
        return 0;

    static if (isUnsignedFixedInt!F)
    {
        return F(1) << clz(x);
    }
    else
    {
        bool negative = cast(bool)(data[$ - 1] & SIGN_BITS);
        FixedInt!(bits, false) x = negative ? -x : x;
        x <<= clz(x);
        return F(negative ? x : -x);
    }
}

private:

template isSomeUnsigned(T)
{
    static if (isIntegral!T)
        enum isSomeUnsigned = isUnsigned!T;
    else static if (isFixedInt!T)
        enum isSomeUnsigned = !T._signed;
    else static if (isSomeChar!T || is(Unqual!T == bool))
        enum isSomeUnsigned = true;
    else
        enum isSomeUnsigned = false;
}

template isSomeSigned(T)
{
    static if (isIntegral!T)
        enum isSomeSigned = isSigned!T;
    else static if (isFixedInt!T)
        enum isSomeSigned = T._signed;
    else
        enum isSomeSigned = false;
}

public:

/** 
* Detects whether T is a fixed integral type. 
* Built-in integral types are not considered
*/
template isFixedInt(T)
{
    enum isFixedInt = is(T : FixedInt!(bits, signed), uint bits, bool signed);
}

///
unittest
{
    static assert (isFixedInt!uint128);
    static assert (isFixedInt!int128);
    static assert (!isFixedInt!uint);
    static assert (!isFixedInt!int);
}

/** 
* Detects whether T is an unsigned fixed integral type. 
* Built-in integral types are not considered
*/
template isUnsignedFixedInt(T)
{
    enum isUnsignedFixedInt = is(T : FixedInt!(bits, signed), uint bits, bool signed = false);
}

///
unittest
{
    static assert (isUnsignedFixedInt!uint128);
    static assert (!isUnsignedFixedInt!int128);
    static assert (!isUnsignedFixedInt!uint);
    static assert (!isUnsignedFixedInt!int);
}

/** 
* Detects whether T is a signed fixed integral type. 
* Built-in integral types are not considered
*/
template isSignedFixedInt(T)
{
    enum isSignedFixedInt = is(T : FixedInt!(bits, signed), uint bits, bool signed = true);
}


///
unittest
{
    static assert (!isSignedFixedInt!uint128);
    static assert (isSignedFixedInt!int128);
    static assert (!isSignedFixedInt!uint);
    static assert (!isSignedFixedInt!int);
}




