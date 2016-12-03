/**
* Unsigned integer functions
*
* Copyright: Copyright Răzvan Ștefănescu 2016.
* License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
* Authors:   Răzvan Ștefănescu 
* Source:    $(NUMERICSSRC internal/integrals.d)
*/
module numerics.internal.integrals;

private import core.bitop: bsr, bsf;

///returns true if x is a power of 2
pragma(inline, true)
@safe pure nothrow @nogc
bool ispow2(const uint x)
{
    return (x & (x - 1)) == 0;
}

///returns true if x is a power of 2
pragma(inline, true)
@safe pure nothrow @nogc
bool ispow2(const ulong x)
{
    return x != 0 && (x & (x - 1)) == 0;
}

///counts leading zeros
@safe pure nothrow @nogc
auto clz(const uint x)
{
    return x ? 31 - bsr(x) : 0;
}

///counts leading zeros
@safe pure nothrow @nogc
auto clz(const ulong x)
{
    if (!x)
        return 64;
    static if (is(size_t == ulong))
        return 63 - bsr(x);
    else static if(is(size_t == uint))
    {
        immutable hi = cast(uint)(x >> 32);
        if (hi)
            return 31 - bsr(hi);
        else
            return 63 - bsr(cast(uint)x);
    }
    else
        static assert(0);
}


///counts trailing zeros in a int
@safe pure nothrow @nogc
auto ctz(const uint x)
{
    return x ? bsf(x) : 0;
}

///counts trailing zeros in a long
@safe pure nothrow @nogc
auto ctz(const ulong x)
{
    if (!x)
        return 64;
    static if (is(size_t == ulong))
        return bsf(x);
    else static if (is(size_t == uint))
    {
        immutable lo = cast(uint)x;
        if (lo)
            return bsf(lo);
        else
            return bsf(cast(uint)(x >> 32)) + 32;
    }
    else
        static assert(0);
}
