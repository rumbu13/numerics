/**
* Array functions
*
* Copyright: Copyright Răzvan Ștefănescu 2016.
* License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
* Authors:   Răzvan Ștefănescu 
* Source:    $(NUMERICSSRC internal/arrays.d)
*/
module numerics.internal.arrays;

import numerics.internal.integrals;

alias ispow2 = numerics.internal.integrals.ispow2;
alias clz    = numerics.internal.integrals.clz;
alias ctz    = numerics.internal.integrals.ctz;


enum ZERO_BITS = 0x0000_0000U;
enum ONE_BITS  = 0xFFFF_FFFFU;
enum SIGN_BITS = 0x8000_0000U;


@safe pure nothrow @nogc
private bool all_generic(const(uint)[] x, const uint y)
{
    for(size_t i = 0; i < x.length; ++i)
        if (x[i] != y)
            return false;
    return true;
}

@safe pure nothrow @nogc
bool all(const(uint)[] x, const uint y)
{
    version (D_InlineAsm_X86)
    {
        if (__ctfe)
            return all_generic(x, y);

        enum pushes = 0;
        enum last_param = pushes * 4 + 4;
        enum xlen = last_param + 0 * 4;
        enum xptr = last_param + 1 * 4;

        asm @safe pure nothrow @nogc
        {
            naked;
            mov ECX, dword ptr [ESP + xlen];
            test ECX, ECX;
            jz return_true;
            mov EDX, dword ptr [ESP + xptr];
            cmp EAX, dword ptr [EDX];
            jne return_false;;
            lea EDX, [EDX + ECX * 4];
            neg ECX;
            add ECX, 1;
            jz return_true;
        all_loop:
            cmp EAX, dword ptr [EDX + ECX * 4];
            jne return_false;
            add ECX, 1;
            jnz all_loop;
        return_true:
            mov EAX, 1;
            ret 2 * 4;
        return_false:
            xor EAX, EAX;
            ret 2 * 4;
        }
    }
    else
    {
        return all_generic(x, y);
    }
}

///x = y;
@safe pure nothrow @nogc
void mov(uint[] x, const uint y)
{
    assert(x.length >= 1);
    x[0] = y;
    x[1 .. $] =  ZERO_BITS;
}


///x = y;
@safe pure nothrow @nogc
void movs(uint[] x, const int y)
{
    assert(x.length >= 1);
    x[0] = y;
    x[1 .. $] =  y < 0 ? ONE_BITS : ZERO_BITS; 
}

///x = y
@safe pure nothrow @nogc
void mov(uint[] x, const ulong y)
{
    assert(x.length >= 2);
    x[0] = cast(uint)y;
    x[1] = cast(uint)(y >>> 32);
    x[2 .. $] = ZERO_BITS;
}

@safe pure nothrow @nogc
void movs(uint[] x, const long y)
{
    assert(x.length >= 2);
    x[0] = cast(uint)y;
    x[1] = cast(uint)(y >>> 32);
    x[2 .. $] =  y < 0 ? ONE_BITS : ZERO_BITS; 
}

///x = y;
@safe pure nothrow @nogc
void mov(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length]= y[];
    x[y.length .. $] = ZERO_BITS;
}

///x = y;
@safe pure nothrow @nogc
void movs(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length]= y[];
    x[y.length .. $] = y.length && (y[$ - 1] & SIGN_BITS) ? ONE_BITS : ZERO_BITS;
}

///x == y
@safe pure nothrow @nogc
bool equuu(const(uint)[] x, const uint y)
{
    if (x.length > 1)
        return x[0] == y && all(x[1 .. $], ZERO_BITS);
    else if (x.length == 1)
        return x[0] == y;
    else
        return y == 0; 
}

///x == y
@safe pure nothrow @nogc
bool equuu(const(uint)[] x, const ulong y)
{
    if (x.length > 2)
        return (cast(ulong)x[1] << 32 | x[0]) == y && all(x[2 .. $], ZERO_BITS);
    if (x.length == 2)
        return (cast(ulong)x[1] << 32 | x[0]) == y;
    else if (x.length == 1)
        return x[0] == y;
    else
        return y == 0;
}

///x == y
@safe pure nothrow @nogc
bool equuu(const(uint)[] x, const(uint)[] y)
{
    if (x.length == y.length)
        return x[] == y[];
    else if (x.length > y.length)
        return x[0 .. y.length] == y[] && all(x[y.length .. $], ZERO_BITS);
    else
        return x[] == y[0 .. x.length] && all(y[x.length .. $], ZERO_BITS); 
}

///x == y
@safe pure nothrow @nogc
bool equss(const(uint)[] x, const int y)
{
    if (x.length > 1)
        return x[0] == y && all(x[1 .. $], y < 0 ? ONE_BITS : ZERO_BITS);
    else if (x.length == 1)
        return x[0] == y;
    else
        return y == 0; 
}

///x == y
@safe pure nothrow @nogc
bool equss(const(uint)[] x, const long y)
{
    if (x.length > 2)
        return (cast(ulong)x[1] << 32 | x[0]) == y && all(x[1 .. $], y < 0 ? ONE_BITS : ZERO_BITS);
    else if (x.length == 2)
        return (cast(ulong)x[1] << 32 | x[0]) == y;
    else if (x.length == 1)
        return cast(int)x[0] == y;
    else
        return y == 0; 
}

///x == y
@safe pure nothrow @nogc
bool equss(const(uint)[] x, const(uint)[] y)
{
    if (x.length == y.length)
        return x[] == y[];
    else 
    {
        bool sx = x.length >= 1 && (x[$ - 1] & SIGN_BITS) != 0;
        bool sy = y.length >= 1 && (y[$ - 1] & SIGN_BITS) != 0;
        if (sx != sy)
            return false;
        else if (x.length > y.length)
            return x[0 .. y.length] == y[] && all(x[y.length .. $], sx ? ONE_BITS : ZERO_BITS);
        else
            return x[] == y[0 .. x.length] && all(y[x.length .. $], sx ? ONE_BITS : ZERO_BITS); 
    }
}

///x == y
@safe pure nothrow @nogc
bool equus(const(uint)[] x, const int y)
{
    return y >= 0 && equuu(x, y);
}

///x == y
@safe pure nothrow @nogc
bool equus(const(uint)[] x, const long y)
{
    return y >= 0 && equuu(x, y);
}

///x == y
@safe pure nothrow @nogc
bool equus(const(uint)[] x, const(uint)[] y)
{
    return ((y.length > 0 && !(y[$ - 1] & SIGN_BITS)) || y.length == 0) && equuu(x, y);
}

///x == y
@safe pure nothrow @nogc
bool equsu(const(uint)[] x, const uint y)
{
    return ((x.length > 0 && !(x[$ - 1] & SIGN_BITS)) || x.length == 0) && equuu(x, y);
}

///x == y
@safe pure nothrow @nogc
bool equsu(const(uint)[] x, const ulong y)
{
    return ((x.length > 0 && !(x[$ - 1] & SIGN_BITS)) || x.length == 0) && equuu(x, y);
}

///x == y
@safe pure nothrow @nogc
bool equsu(const(uint)[] x, const(uint)[] y)
{
    return ((x.length > 0 && !(x[$ - 1] & SIGN_BITS)) || x.length == 0) && equuu(x, y);
}

///x ? y
@safe pure nothrow @nogc
int cmpuu(const(uint)[] x, const uint y)
{
    if (x.length == 0)
        return y ? -1 : 0;
    if (x[0] > y)
        return 1;
    if (x.length > 1 && !all(x[1 .. $], ZERO_BITS))
        return 1;
    if (x[0] < y)
        return -1;
    return 0;
}

///x ? y
@safe pure nothrow @nogc
int cmpuu(const(uint)[] x, const ulong y)
{
    if (x.length == 0)
        return y ? -1 : 0;
    if (x[0] > y)
        return 1;
    if (x.length > 2 && !all(x[2 .. $], ZERO_BITS))
        return 1;
    if (x.length == 1)
        return x[0] < y ? -1 : 0;
    auto xx = cast(ulong)x[1] << 32 | x[0];
    return xx < y ? -1 : (xx > y ? 1 : 0);
}

///x ? y
@safe pure nothrow @nogc
int cmpuu(const(uint)[] x, const(uint)[] y)
{
    auto len = x.length <= y.length ? x.length : y.length;
    if (x.length > len && !all(x[len .. $], ZERO_BITS))
        return 1;
    if (y.length > len && !all(y[len .. $], ZERO_BITS))
        return -1;
    for (ptrdiff_t i = len - 1; i >= 0; --i)
    {
        if (x[i] > y[i])
            return 1;
        else if (x[i] < y[i])
            return -1;
    }
    return 0;
}

///x ? y
@safe pure nothrow @nogc
int cmpss(const(uint)[] x, const int y)
{
    if (x.length == 0)
        return y > 0 ? -1 : (y < 0 ? 1: 0);
    if (x.length == 1)
        return cast(int)x[0] > y ? 1: (cast(int)x[0] < y ? -1 : 0);
    bool sx = (x[$ - 1] & SIGN_BITS) != 0;
    bool sy = y < 0;
    if (sx && !sy)
        return -1;
    if (!sx && sy)
        return 1;
    if (!sx)
    {
        if (!all(x[1 .. $], ZERO_BITS))
            return 1;
        if (x[0] > y)
            return 1;
        if (x[0] < y)
            return -1;
    }
    else
    {
        if (!all(x[1 .. $], ONE_BITS))
            return 1;
        if (x[0] > y)
            return 1;
        if (x[0] < y)
            return -1;
    }
    return 0;
}

///x ? y
@safe pure nothrow @nogc
int cmpss(const(uint)[] x, const long y)
{
    if (x.length == 0)
        return y > 0 ? -1 : (y < 0 ? 1: 0);
    if (x.length == 1)
        return cast(int)x[0] > y ? 1: (cast(int)x[0] < y ? -1 : 0);
    if (x.length == 2)
    {
        auto xx = cast(ulong)x[1] << 32 | x[0];
        return cast(long)xx > y ? 1: (cast(long)xx < y ? -1 : 0);
    }
    bool sx = (x[$ - 1] & SIGN_BITS) != 0;
    bool sy = y < 0;
    if (sx && !sy)
        return -1;
    if (!sx && sy)
        return 1;
    auto xx = cast(long)(cast(ulong)x[1] << 32 | x[0]);
    if (!sx)
    {
        if (!all(x[2 .. $], ZERO_BITS))
            return 1;
        if (xx > y)
            return 1;
        if (xx < y)
            return -1;
    }
    else
    {
        if (!all(x[2 .. $], ONE_BITS))
            return 1;
        if (xx > y)
            return 1;
        if (xx < y)
            return -1;
    }
    return 0;
}

///x ? y
@safe pure nothrow @nogc
int cmpss(const(uint)[] x, const(uint)[] y)
{
    bool sx = x.length > 0 && (x[$ - 1] & SIGN_BITS) != 0;
    bool sy = y.length > 0 && (y[$ - 1] & SIGN_BITS) != 0;
    if (sx && !sy)
        return -1;
    if (!sx && sy)
        return 1;
    auto len = x.length <= y.length ? x.length : y.length;

    if (x.length > len && !all(x[len .. $], sx ? ONE_BITS : ZERO_BITS))
        return 1;
    if (y.length > len && !all(y[len .. $], sx ? ONE_BITS : ZERO_BITS))
        return -1;
    for (ptrdiff_t i = len - 1; i >= 0; --i)
    {
        if (x[i] > y[i])
            return 1;
        else if (x[i] < y[i])
            return -1;
    }
    return 0;
}

///x ? y
@safe pure nothrow @nogc
int cmpus(const(uint)[] x, const int y)
{
    if (y < 0)
        return 1;
    else
        return cmpuu(x, y);
}

///x ? y
@safe pure nothrow @nogc
int cmpus(const(uint)[] x, const long y)
{
    if (y < 0)
        return 1;
    else
        return cmpuu(x, y);
}


///x ? y
@safe pure nothrow @nogc
int cmpus(const(uint)[] x, const(uint)[] y)
{
    if (y.length > 0 && (y[$ -1] & SIGN_BITS))
        return 1;
    else
        return cmpuu(x, y);
}

///x ? y
@safe pure nothrow @nogc
int cmpsu(const(uint)[] x, const uint y)
{
    if (x.length > 0 && (x[$ - 1] & SIGN_BITS))
        return -1;
    else
        return cmpuu(x, y);
}

///x ? y
@safe pure nothrow @nogc
int cmpsu(const(uint)[] x, const ulong y)
{
    if (x.length > 0 && (x[$ - 1] & SIGN_BITS))
        return -1;
    else
        return cmpuu(x, y);
}

///x ? y
@safe pure nothrow @nogc
int cmpsu(const(uint)[] x, const(uint)[] y)
{
    if (x.length > 0 && (x[$ - 1] & SIGN_BITS))
        return -1;
    else
        return cmpuu(x, y);
}

///x |= y
pragma(inline, true);
@safe pure nothrow @nogc
void or(uint[] x, const uint y)
{
    assert(x.length >= 1);
    x[0] |= y;
}

///z = x | y
pragma(inline, true);
@safe pure nothrow @nogc
void or(uint[] z, const(uint)[] x, const uint y)
{
    assert(z.length >= x.length);
    assert(x.length >= 1);
    z[0] = x[0] | y;
    mov(z[1 .. $], x[1 .. $]);
}

///x |=y
pragma(inline, true);
@safe pure nothrow @nogc
void or(uint[] x, const ulong y)
{
    assert(x.length >= 2);
    x[0] |= cast(uint)y;
    x[1] |= cast(uint)(y >>> 32);
}


///x |= y
pragma(inline, true);
@safe pure nothrow @nogc
void or(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length] |= y[];
}

///x |= y
pragma(inline, true);
@safe pure nothrow @nogc
void ors(uint[] x, const int y)
{
    assert(x.length >= 1);
    x[0] |= y;
    if (y < 0)
        x[1 .. $] = ONE_BITS;
}

///x |= y
pragma(inline, true);
@safe pure nothrow @nogc
void ors(uint[] x, const long y)
{
    assert(x.length >= 2);
    x[0] |= cast(uint)y;
    x[1] |= cast(uint)(y >>> 32);
    if (y < 0)
        x[2 .. $] = ONE_BITS;
}

///x |= y
pragma(inline, true);
@safe pure nothrow @nogc
void ors(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length] |= y[];
    if (y.length && (y[$ - 1] & SIGN_BITS))
        x[y.length .. $] = ONE_BITS;
}

///x &= y
pragma(inline, true);
@safe pure nothrow @nogc
void and(uint[] x, const uint y)
{
    assert(x.length >= 1);
    x[0] &= y;
    x[1 .. $] = ZERO_BITS;
}

///x &= y
pragma(inline, true);
@safe pure nothrow @nogc
void and(uint[] x, const ulong y)
{
    assert(x.length >= 2);
    x[0] &= cast(uint)y;
    x[1] &= cast(uint)(y >>> 32);
    x[2 .. $] = ZERO_BITS;
}

///x &= y
pragma(inline, true);
@safe pure nothrow @nogc
void and(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length] &= y[];
    x[y.length .. $] = ZERO_BITS;
}

///x &= y
pragma(inline, true);
@safe pure nothrow @nogc
void ands(uint[] x, const int y)
{
    assert(x.length >= 1);
    x[0] &= y;
    if (y >= 0)
        x[1 .. $] = ZERO_BITS;
}

///x &= y
pragma(inline, true);
@safe pure nothrow @nogc
void ands(uint[] x, const long y)
{
    assert(x.length >= 2);
    x[0] &= cast(uint)y;
    x[1] &= cast(uint)(y >>> 32);
    if (y >= 0)
        x[2 .. $] = ZERO_BITS;
}

///x &= y
pragma(inline, true);
@safe pure nothrow @nogc
void ands(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length] &= y[];
    if ((y.length && !(y[$ - 1] & SIGN_BITS)) || !y.length)
        x[y.length .. $] = ZERO_BITS;
}

///x ^= y
pragma(inline, true);
@safe pure nothrow @nogc
void xor(uint[] x, const uint y)
{
    assert(x.length >= 1);
    x[0] ^= y;
}

///x ^= y
pragma(inline, true);
@safe pure nothrow @nogc
void xor(uint[] x, const ulong y)
{
    assert(x.length >= 2);
    x[0] ^= cast(uint)y;
    x[1] ^= cast(uint)(y >>> 32);
}

///x ^= y
pragma(inline, true);
@safe pure nothrow @nogc
void xor(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length] ^= y[];
}

///x ^= y
pragma(inline, true);
@safe pure nothrow @nogc
void xors(uint[] x, const int y)
{
    assert(x.length >= 1);
    x[0] ^= y;
    if (y < 0)
        not(x[1 .. $]);
}

///x ^= y
pragma(inline, true);
@safe pure nothrow @nogc
void xors(uint[] x, const long y)
{
    assert(x.length >= 2);
    x[0] ^= cast(uint)y;
    x[1] ^= cast(uint)(y >>> 32);
    if (y < 0)
        not(x[2 .. $]);
}

///x ^= y
pragma(inline, true);
@safe pure nothrow @nogc
void xors(uint[] x, const(uint)[] y)
{
    assert(x.length >= y.length);
    x[0 .. y.length] ^= y[];
    if (y.length && (y[$ - 1] & SIGN_BITS))
        not(x[y.length .. $]);
}

pragma(inline, true);
@safe pure nothrow @nogc
void not(uint[] x)
{
    x[] = ~x[];
}


@safe pure nothrow @nogc
uint inc(uint[] x)
{
    version (D_InlineAsm_X86)
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
            ret 2 * 4;
        }
    }
    else
    {
        for (size_t i = 0; i < x.length; ++i)
            if (++x[i])
                return 0;
        return 1;
    }
}

@safe pure nothrow @nogc
uint dec(uint[] x)
{
    version (D_InlineAsm_X86)
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
        dec_loop:
            sub dword ptr [EDX + EAX * 4], 1;
            jnc no_carry;
            add EAX, 1;
            cmp EAX, ECX;
            jb dec_loop;
            jmp carry;
        no_carry:
            xor EAX, EAX;
            ret 2 * 4;
        carry:
            mov EAX, 1;
            ret 2 * 4;
        }
    }
    else
    {
        for (size_t i = 0; i < x.length; ++i)
            if (x[i]--)
                return 0;
        return 1;
    }
    
}

@safe pure nothrow @nogc
void neg(uint[] x)
{
    version (D_InlineAsm_X86)
    {
        enum pushes = 0;
        enum last_param = pushes * 4 + 4;
        enum xlen = last_param;
        enum xptr = last_param + 4 * 1;
        asm @safe pure nothrow @nogc
        {
            naked;
            mov ECX, dword ptr [ESP + xlen];
            test ECX, ECX;
            jz cleanup;
            mov EDX, dword ptr [ESP + xptr];
            lea EDX, [EDX + ECX * 4];
            neg ECX;
        zero_loop:
            mov EAX, dword ptr [EDX + ECX * 4];
            test EAX, EAX;
            jnz not_;
            add ECX, 1;
            jnz zero_loop;
        not_:
            test ECX, ECX;
            jz cleanup;
            mov EAX, ECX;
        not_loop:          
            not dword ptr [EDX + ECX * 4];
            add ECX, 1;
            jnz not_loop;
        inc_loop:
            inc dword ptr [EDX + EAX * 4];
            jnz cleanup;
            add EAX, 1;
            jnz inc_loop;
        cleanup:
            ret 2 * 4;
        }
    }
    else
    {
        size_t i = 0;
        while (i < x.length && !x[i])
            ++i;
        if (i < x.length)
        {
            not(x[i .. $]);
            inc(x[i .. $]);
        }
    }
}

///x += y
@safe pure nothrow @nogc
uint add(uint[] x, const uint y)
{
    assert(x.length >= 1);
    x[0] += y;
    return x[0] < y ? inc(x[1 .. $]): 0;
}


///x += y
@safe pure nothrow @nogc
uint add(uint[] x, const ulong y)
{
    assert(x.length >= 2);
    ulong xx = cast(ulong)(x[1]) << 32 | x[0];
    xx += y;
    x[0] = cast(uint)xx;
    x[1] = cast(uint)(xx >>> 32);
    return xx < y ? inc(x[2 .. $]): 0;
}

///x += y
@safe pure nothrow @nogc
uint add(uint[] x, const(uint)[] y)
{
    version(D_InlineAsm_X86)
    {
        enum pushes = 2;
        enum last_param = pushes * 4 + 4;
        enum ylen = last_param;
        enum yptr = last_param + 4 * 1;
        enum xlen = last_param + 4 * 2;
        enum xptr = last_param + 4 * 3;
        
        asm @safe pure nothrow @nogc
        {
            naked;
            push ESI;
            push EDI;
            mov ECX, dword ptr [ESP + ylen];
            xor EAX, EAX;
            test ECX, ECX;
            jz cleanup;
            mov EDI, dword ptr [ESP + xptr];
            mov ESI, dword ptr [ESP + yptr];
            lea EDI, [EDI + ECX * 4];
            lea ESI, [ESI + ECX * 4];
            neg ECX;
        add_loop:
            xor EDX, EDX;
            add EAX, dword ptr [EDI + ECX * 4];
            adc EDX, 0;
            add EAX, dword ptr [ESI + ECX * 4];
            adc EDX, 0;
            mov dword ptr [EDI + ECX * 4], EAX;
            mov EAX, EDX;
            add ECX, 1;
            jnz add_loop;
            test EAX, EAX;
            jz cleanup;
        carry:
            mov EDX, dword ptr [ESP + xlen];
            mov ECX, EDX;
            sub EDX, dword ptr [ESP + ylen];
            jz cleanup;
            mov EDI, dword ptr [ESP + xptr];
            lea EDI, [EDI + ECX * 4];
            neg EDX;
        add_carry:
            add EAX, dword ptr [EDI + EDX * 4];
            mov dword ptr [EDI + EDX * 4], EAX;
            jnc no_carry;
            mov EAX, 1;
            add EDX, 1;
            jnz add_carry;
            jmp cleanup;
        no_carry:
            xor EAX, EAX;
        cleanup:
            pop EDI;
            pop ESI;
            ret 4 * 4;
        }
    }
    else
    {
        assert(x.length >= y.length);
        uint carry;
        for (size_t i = 0; i < y.length; ++i)
        {
            x[i] += carry;
            carry = x[i] < carry;
            x[i] += y[i];
            carry += x[i] < y[i];           
        }
        if (carry && x.length > y.length)
            carry = add(x[y.length .. $], carry);
        return carry;
    }
}

///x -= y
@safe pure nothrow @nogc
uint sub(uint[] x, const uint y)
{
    assert(x.length >= 1);
    bool carry = x[0] < y;
    x[0] -= y; 
    return carry ? dec(x[1 .. $]): 0;
}


///x -= y
@safe pure nothrow @nogc
uint sub(uint[] x, const ulong y)
{
    assert(x.length >= 2);
    ulong xx = cast(ulong)(x[1]) << 32 | x[0];
    bool carry = xx < y;
    xx -= y;
    x[0] = cast(uint)xx;
    x[1] = cast(uint)(xx >>> 32);
    return carry ? dec(x[2 .. $]): 0;
}

///x -= y
@safe pure nothrow @nogc
uint sub(uint[] x, const(uint)[] y)
{
    
    version(D_InlineAsm_X86)
    {
        enum pushes = 3;
        enum last_param = pushes * 4 + 4;
        enum ylen = last_param;
        enum yptr = last_param + 4 * 1;
        enum xlen = last_param + 4 * 2;
        enum xptr = last_param + 4 * 3;

        asm @safe pure nothrow @nogc
        {
            naked;
            push ESI;
            push EDI;
            push EBX;
            mov ECX, dword ptr [ESP + ylen];
            xor EAX, EAX;
            test ECX, ECX;
            jz cleanup;
            mov EDI, dword ptr [ESP + xptr];
            mov ESI, dword ptr [ESP + yptr];
            lea EDI, [EDI + ECX * 4];
            lea ESI, [ESI + ECX * 4];
            neg ECX;
        sub_loop:
            xor EDX, EDX;
            mov EBX, dword ptr [EDI + ECX * 4];
            sub EBX, EAX;
            adc EDX, 0;
            sub EBX, dword ptr [ESI + ECX * 4];
            adc EDX, 0;
            mov dword ptr [EDI + ECX * 4], EBX;
            mov EAX, EDX;
            add ECX, 1;
            jnz sub_loop;
            test EAX, EAX;
            jz cleanup;
        carry:
            mov EDX, dword ptr [ESP + xlen];
            mov ECX, EDX;
            sub EDX, dword ptr [ESP + ylen];
            jz cleanup;
            mov EDI, dword ptr [ESP + xptr];
            lea EDI, [EDI + ECX * 4];
            neg EDX;
        sub_carry:
            sub dword ptr [EDI + EDX * 4], EAX;
            jnc no_carry;
            mov EAX, 1;
            add EDX, 1;
            jnz sub_carry;
            jmp cleanup;
        no_carry:
            xor EAX, EAX;
        cleanup:
            pop EBX;
            pop EDI;
            pop ESI;
            ret 4 * 4;
        }
    }
    else
    {
        assert(x.length >= y.length);
        uint carry;
        for (size_t i = 0; i < y.length; ++i)
        {
            uint c = x[i] < carry;
            x[i] -= carry;
            carry = c;
            c = x[i] < y[i];
            x[i] -= y[i];
            carry += c;
        }

        if (carry && x.length > y.length)
            carry = sub(x[y.length .. $], carry);
        return carry;
    }
}

/// x <<= y
@safe pure nothrow @nogc
void shl(uint[] x, const size_t y)
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
        x[0 .. bigShift] = ZERO_BITS;
}

/// x >>>= y
@safe pure nothrow @nogc
void shr(uint[] x, const size_t y)
{  
    assert(x.length);
    assert(y);
    assert(y < x.length * 32);

    immutable bigShift = y / 32;
    immutable smallShift = y % 32;

    if (smallShift == 0) 
    {
        for (size_t i = bigShift; i < x.length; ++i) 
            x[i - bigShift] = x[i]; 
    }
    else
    { 
        immutable carryShift = 32 - smallShift;
        size_t i;
        for (i = bigShift; i < x.length - 1; ++i) 
        {
            x[i - bigShift] = x[i] >>> smallShift;
            x[i - bigShift] |= x[i + 1] << carryShift; 
        }
        x[i - bigShift] = x[i] >>> smallShift;
    }             

    if (bigShift < x.length)
        x[$ - bigShift .. $] = ZERO_BITS;
}

/// x >>= y
@safe pure nothrow @nogc
void sahr(uint[] x, const size_t y)
{  
    assert(x.length);
    assert(y);
    assert(y < x.length * 32);

    immutable bigShift = y / 32;
    immutable smallShift = y % 32;

    bool negative = (x[$ - 1] & SIGN_BITS) != 0;

    if (smallShift == 0) 
    {
        for (size_t i = bigShift; i < x.length; ++i) 
            x[i - bigShift] = x[i]; 
    }
    else
    { 
        immutable carryShift = 32 - smallShift;
        size_t i;
        for (i = bigShift; i < x.length - 1; ++i) 
        {
            x[i - bigShift] = x[i] >>> smallShift;
            x[i - bigShift] |= x[i + 1] << carryShift; 
        }
        x[i - bigShift] = cast(int)(x[i]) >> smallShift;
    }             

    if (bigShift < x.length)
        x[$ - bigShift .. $] = negative ? ONE_BITS : ZERO_BITS;
}

/// x *= y
@safe pure nothrow @nogc
uint mul_basecase(uint[] x, const uint y)
{
    version(D_InlineAsm_X86)
    {
        enum pushes = 4;
        enum last_param = pushes * 4 + 4;
        enum xlen = last_param;
        enum xptr = last_param + 4;
        //eax = y
        //esp + 4 x.length
        //esp + 8 x.ptr
        asm pure @safe nothrow @nogc
        {
            naked;
            push EBX;
            push ESI;
            push EDI;
            push EBP;
            mov EBP, EAX;
            xor EAX, EAX;
            mov ECX, dword ptr [ESP + xlen];
            test ECX, ECX;
            jz cleanup;
            mov EBX, dword ptr [ESP + xptr];
            lea EBX, [EBX + ECX * 4];
            neg ECX;          
            xor EDI, EDI;
        mul_loop:
            xor ESI, ESI;
            mov EAX, dword ptr [EBX + ECX * 4];
            mul EBP;
            add EDI, EAX;
            adc ESI, EDX;
            mov dword ptr [EBX + ECX * 4], EDI;
            mov EDI, ESI;
            add ECX, 1;
            jnz mul_loop;
            mov EAX, EDI;
        cleanup:
            pop EBP;
            pop EDI;
            pop ESI;
            pop EBX;
            ret 2 * 4;
        }
    }
    else
    {
        ulong carry = 0;
        for (size_t i = 0; i < x.length; ++i)
        {
            carry += x[i] * cast(ulong)y;
            x[i] = cast(uint)carry;
            carry >>= 32;
        }
        return cast(uint)carry;
    }
}

///x *= y
@safe pure nothrow @nogc
uint mul(uint[] x, const uint y)
{
  
    if (y == 0)
    {
        x[] = ZERO_BITS;
        return 0;
    }

    if (y == 1)
        return 0;

    auto usedx = used(x);

    if (usedx == 0)
        return 0;

    if (usedx == 1)
    {
        if (x[0] == 1)
        {
            x[0] = y;
            return 0;
        }
        ulong ret = xmul(x[0], y);
        x[0] = cast(uint)ret;
        if (x.length > 1)
        {
            x[1] = cast(uint)(ret >> 32);
            return 0;
        }
        return cast(uint)(ret >> 32);
    }

    if (ispow2(y))
    {
        auto shift = ctz(y);
        auto carry = x[$ - 1] >>> (32 - shift);
        shl(x, shift);
        return carry;
    }
    
    auto carry = mul_basecase(x[0 .. usedx], y);
    if (carry && usedx < x.length)
    {
        x[usedx] = carry;
        carry = 0;
    }
    return carry;

}


///z = x * y
@safe pure nothrow @nogc
void mul_basecase(uint[] z, const(uint)[] x, const(uint)[] y)
{
    version(D_InlineAsm_X86)
    {
        enum pushes = 4;
        enum locals = 2;
        enum last_param = locals * 4 + pushes * 4 + 4;
        enum ylen = last_param;
        enum yptr = last_param + 4 * 1;
        enum xlen = last_param + 4 * 2;
        enum xptr = last_param + 4 * 3;
        enum zlen = last_param + 4 * 4;
        enum zptr = last_param + 4 * 5;
        asm pure @safe nothrow @nogc
        {
            naked;
            push EBX;
            push ESI;
            push EDI;
            push EBP;
            sub ESP, locals * 4;
            mov ECX, dword ptr [ESP + zlen];
            mov EDI, dword ptr [ESP + zptr];
            xor EAX, EAX;
            rep;
            stosd;

            //EAX, EDX scratch
            //ESI = x, counter ECX
            //EDI = y, counter EBX
            //EBP = z

            mov EBP, dword ptr [ESP + zptr];
            mov EBX, dword ptr [ESP + ylen];
            mov EDI, dword ptr [ESP + yptr];
            lea EDI, [EDI + EBX * 4];
            neg EBX;
        outerloop:
            mov ECX, dword ptr [ESP + xlen];
            mov ESI, dword ptr [ESP + xptr];
            lea ESI, [ESI + ECX * 4];
            neg ECX;
            mov dword ptr [ESP], 0;
            mov dword ptr [ESP + 4], EBP;       //save z index
        innerloop:
            mov EAX, dword ptr [ESI + ECX * 4];
            mul dword ptr [EDI + EBX * 4];
            add EAX, dword ptr [EBP];
            adc EDX, 0;
            add EAX, dword ptr [ESP];
            adc EDX, 0;
            mov dword ptr [EBP], EAX;
            mov dword ptr [ESP], EDX;
            add EBP, 4;
            add ECX, 1;
            jnz innerloop;
            mov dword ptr [EBP], EDX;
            mov EBP, dword ptr [ESP + 4];  //restore z index;
            add EBP, 4;
            add EBX, 1;
            jnz outerloop;

        cleanup:
            add ESP, locals * 4;
            pop EBP;
            pop EDI;
            pop ESI;
            pop EBX;
            ret 6 * 4;
        }
    }
    else
    {
        assert(x.length >= y.length);
        assert(z.length >= x.length + y.length);

        z[] = ZERO_BITS;

        for (size_t i = 0; i < y.length; ++i)
        {
            ulong carry = 0;
            for (size_t j = 0; j < x.length; ++j)
            {
                carry += z[i + j] + cast(ulong)x[j] * y[i];
                z[i + j] = cast(uint)carry;
                carry >>= 32;
            }
            z[i + x.length] = cast(uint)carry;
        }
    }
}


///z = x^^2
@safe pure nothrow @nogc
void squ_basecase(uint[] z, const(uint)[] x)
{
    assert(z.length >= x.length * 2);
    for (size_t i = 0; i < x.length; ++i)
    {
        ulong carry = 0;
        for (size_t j = 0; j < i; j++)
        {
            ulong a = z[i + j] + carry;
            ulong b = xmul(x[j], x[i]);
            z[i + j] = cast(uint)(a + (b << 1));
            carry = (b + (a >> 1)) >> 31;
        }
        carry += xmul(x[i], x[i]);
        z[i + i] = cast(uint)carry;
        z[i + i + 1] = cast(uint)(carry >> 32);
    }
    if (z.length > x.length * 2)
        z[x.length * 2 .. $] = ZERO_BITS;
}

///z = x * y
@safe pure nothrow @nogc
void mul(uint[] z, const(uint)[] x, const(uint)[] y)
{
    auto usedy = used(y);
    if (usedy == 0)
    {
        z[] = ZERO_BITS;
        return;
    }

    if (usedy == 1)
    {
        mov(z, x);
        if (y[0] == 1)
            return;
        mul(z, y[0]);
        return;
    }

    auto usedx = used(x);
    if (usedx == 0)
    {
        z[] = ZERO_BITS;
        return;
    }

    if (usedx == 1)
    {
        mov(z, y);
        if (x[1] == 1)
            return;
        mul(z, x[0]);
        return;
    }

    auto xx = x[0 .. usedx];
    auto yy = y[0 .. usedy];

    if (ispow2(yy))
    {
        mov(z, xx);
        shl(z, ctz(yy));
        return;
    }

    if (ispow2(xx))
    {
        mov(z, yy);
        shl(z, ctz(xx));
        return;
    }

    if (equuu(xx, yy))
        squ_basecase(z, xx);
    else
    {
        if (usedx >= usedy)
            mul_basecase(z, xx, yy);
        else
            mul_basecase(z, yy, xx);
    }
}


///z = x * y
@safe pure nothrow @nogc
void squ(uint[] z, const(uint)[] x)
{
    auto usedx = used(x);
    if (usedx == 0)
    {
        z[] = ZERO_BITS;
        return;
    }

    if (usedx == 1)
    {
        auto xx = xmul(x[0], x[0]);
        mov(z, xx);
        return;
    }

    auto xx = x[0 .. usedx];

    if (ispow2(xx))
    {
        mov(z, xx);
        shl(z, ctz(xx));
        return;
    }
    squ_basecase(z, xx);
}



///x /= y, returns x % y 
@safe pure nothrow @nogc
uint divrem_basecase(uint[] x, const uint y)
{
    version(D_InlineAsm_X86)
    {
        enum pushes = 2;
        enum last_param = pushes * 4 + 4;
        enum xlen = last_param;
        enum xptr = last_param + 4;
        asm pure @safe nothrow @nogc
        {
            naked;
            push EDI;
            push ESI;
            mov ECX, dword ptr [ESP + xlen];    //ECX = xlen
            test ECX, ECX;
            jz cleanup;
            mov ESI, dword ptr [ESP + xptr];    //ESI = xptr            
            mov EDI, EAX;                       //EDI = y;
            xor EDX, EDX;
            sub ESI, 4;
        div_loop:
            mov EAX, dword ptr [ESI + ECX * 4];
            div EDI;       
            mov dword ptr [ESI + ECX * 4], EAX;
            sub ECX, 1;
            jnz div_loop;
            mov EAX, EDX;
        cleanup:
            pop ESI;
            pop EDI;
            ret 2 * 4;

        }
    }
    else
    {
        ulong carry;
        for (ptrdiff_t i = x.length - 1; i >= 0; --i)
        {
            ulong v = (carry << 32) | x[i];
            ulong d = v / y;
            x[i] = cast(uint)d;
            carry = v - d * y;
        }
        return cast(uint)carry;
    }
}

///returns x % y
@safe pure nothrow @nogc
uint rem_basecase(const(uint)[] x, const uint y)
{
    version(D_InlineAsm_X86)
    {
        enum pushes = 2;
        enum last_param = pushes * 4 + 4;
        enum xlen = last_param;
        enum xptr = last_param + 4;
        asm pure @safe nothrow @nogc
        {
            naked;
        save:
            push EDI;
            push ESI;
            mov ECX, dword ptr [ESP + xlen];    //ECX = xlen
            test ECX, ECX;
            jz cleanup;
            mov ESI, dword ptr [ESP + xptr];    //ESI = xptr            
            mov EDI, EAX;                       //EDI = y;
            xor EDX, EDX;
            sub ESI, 4;
        div_loop:
            mov EAX, dword ptr [ESI + ECX * 4];
            div EDI;
            sub ECX, 1;
            jnz div_loop;
            mov EAX, EDX;
        cleanup:
            pop ESI;
            pop EDI;
            ret 2 * 4;
        }
    }
    else
    {
        ulong carry;
        for (ptrdiff_t i = x.length - 1; i >= 0; --i)
        {
            ulong v = (carry << 32) | x[i];
            carry = v % y;
        }
        return cast(uint)carry;
    }
}

///x /= y, returns x % y 
@safe pure nothrow @nogc
uint divrem(uint[] x, const uint y)
{
    if (y == 0)
        return x[0] / y;

    if (y == 1)
        return 0;

    auto usedx = used(x);

    if (usedx == 0)
        return 0;

    if (usedx == 1)
    {
        if (x[0] < y)
        {
            auto r = x[0];
            x[0] = ZERO_BITS;
            return r;
        }

        if (x[0] == y)
        {
            x[0] = 1;
            return 0;
        }

        if (ispow2(y))
        {
            auto r = x[0] & (y - 1);
            x[0] >>>= ctz(y);
            return r;
        }

        auto r = x[0] % y;
        x[0] /= y;
        return r;
    }

    if (usedx == 2)
    {
        ulong xx = cast(ulong)x[1] << 32 | x[0];

        if (ispow2(y))
        {
            xx >>= ctz(y);
            x[0] = cast(uint)xx;
            x[1] = cast(uint)(xx >>> 32);
            return cast(uint)xx & (y - 1);
        }
        
        auto r = cast(uint)(xx % y);
        xx /= y;
        x[0] = cast(uint)xx;
        x[1] = cast(uint)(xx >>> 32);
        return r;
    }

    if (ispow2(y))
    {
        auto r = x[0] & (y - 1);
        shr(x[0 .. usedx], ctz(y));
        return r;
    }

    return divrem_basecase(x[0 .. usedx], y);
}


///returns x % y 
@safe pure nothrow @nogc
uint rem(const(uint)[] x, const uint y)
{
    if (y == 0)
        return x[0] % y;

    if (y == 1)
        return 0;

    auto usedx = used(x);

    if (usedx == 0)
        return 0;

    if (ispow2(y))
        return x[0] & (y - 1);

    if (usedx == 1)
    {
        if (x[0] < y)
            return x[0];

        if (x[0] == y)
            return 0;

        return x[0] % y;
    }

    if (usedx == 2)
        return cast(uint)((cast(ulong)x[1] << 32 | x[0]) % y);

    return rem_basecase(x[0 .. usedx], y);
}


///q = x / y, r = x % y
@safe pure nothrow @nogc
void divrem_basecase(uint[] q, uint[] r, const(uint)[] x, const(uint)[] y)
{
    assert(r.length >= x.length);
    assert(y.length <= x.length);
    assert(y[$ - 1] != ZERO_BITS);

    mov(r, x);
    if (q.length)
        mov(q, ZERO_BITS);
    auto rr = r[0 .. x.length];

    uint yhi = y[$ - 1];
    uint ylo = y.length > 1 ? y[$ - 2] : ZERO_BITS;

    auto shift = clz(yhi);
    auto carryshift = 32 - shift;

    if (shift)
    {
        auto yll = y.length > 2 ? y[$ - 3] : ZERO_BITS;
        yhi = (yhi << shift) | (ylo >>> carryshift);
        ylo = (ylo << shift) | (yll >>> carryshift);
    }

    for (ptrdiff_t i = rr.length; i >= y.length; --i)
    {
        uint msb = i < rr.length ? rr[i] : ZERO_BITS;

        ulong xhi = (cast(ulong)msb << 32) | rr[i - 1];
        uint xlo = i > 1 ? rr[i - 2] : 0;

        if (shift)
        {
            auto xll = i > 2 ? rr[i - 2] : ZERO_BITS;
            xhi = (xhi << shift) | (xlo >>> carryshift);
            xlo = (xlo << shift) | (xll >>> carryshift);
        }

        auto digit = xhi / yhi;

        if (digit > ONE_BITS)
            digit = ONE_BITS;

        auto zhi = xmul(yhi, cast(uint)digit);
        auto zlo = xmul(ylo, cast(uint)digit);
        zhi += zlo >>> 32;
        zlo &= ONE_BITS;

        while (zhi > xhi || (zhi == xhi && zlo > xlo))
        {
            --digit;
            zhi = xmul(yhi, cast(uint)digit);
            zlo = xmul(ylo, cast(uint)digit);
            zhi += zlo >>> 32;
            zlo &= ONE_BITS;
        }
               
        if (digit > 0)
        {
            uint carry = adjust_division_down(rr[i - y.length .. $], y, digit);
            if (carry != msb)
            {
                carry = adjust_division_up(rr[i - y.length .. $], y);
                --digit;
            }
        }

        if (q.length)
            q[i - y.length] = cast(uint)digit;
        if (i < rr.length)
            rr[i] = 0;
    }
    
}




@safe pure nothrow @nogc 
ulong xmul(const uint x, const uint y)
{
    version (D_InlineAsm_X86)
    {
        if (__ctfe)
            return cast(ulong)x * y;
        asm @safe pure nothrow @nogc 
        {
            naked;
            mul dword ptr [ESP + 4];
            ret 4;
        }
    }
    else
        return cast(ulong)x * y;
}

///q = x / y, r = x % y
@safe pure nothrow @nogc
void divrem(uint[] q, uint[] r, const(uint)[] x, const(uint)[] y)
{
    auto usedy = used(y);
    if (usedy <= 1)
    {
        mov(q, x);
        mov(r, divrem(q, y[0]));
        return;
    }

    auto usedx = used(x);

    if (usedx == 0)
    {
        q[] = ZERO_BITS;
        r[] = ZERO_BITS;
        return;
    }

    if (usedx < usedy)
    {
        q[] = ZERO_BITS;
        mov(r, x[0 .. usedx]);
        return;
    }

    auto yy = y[0 .. usedy];
    auto xx = x[0 .. usedx];

    if (usedx == usedy)
    {   
        auto c = cmpuu(xx, yy);
        if (c < 0)
        {
            q[] = ZERO_BITS;
            mov(r, xx);
            return;
        }

        if (c == 0)
        {
            mov(q, 1);
            r[] = ZERO_BITS;
            return;
        }
    }

    if (ispow2(yy))
    {
        mov(q, yy);
        dec(q);
        mov(r, xx);
        and(r, q);
        mov(q, xx);
        shr(q, ctz(yy));
        return;
    }
    
    divrem_basecase(q, r, x[0 .. usedx], y[0 .. usedy]);

}

///q = x / y, r = x % y
@safe pure nothrow @nogc
void rem(uint[] r, const(uint)[] x, const(uint)[] y)
{
    auto usedy = used(y);
    if (usedy <= 1)
    {
        mov(r, rem(x, y[0]));
        return;
    }

    auto usedx = used(x);

    if (usedx == 0)
    {
        r[] = ZERO_BITS;
        return;
    }

    if (usedx < usedy)
    {
        mov(r, x[0 .. usedx]);
        return;
    }

    auto yy = y[0 .. usedy];
    auto xx = x[0 .. usedx];

    if (usedx == usedy)
    {   
        auto c = cmpuu(xx, yy);
        if (c < 0)
        {
            mov(r, xx);
            return;
        }

        if (c == 0)
        {
            r[] = ZERO_BITS;
            return;
        }
    }

    if (ispow2(yy))
    {
        //r = x & (y - 1)
        mov(r, yy);
        dec(r);
        and(r, xx);
        return;
    }

    divrem_basecase(null, r, x[0 .. usedx], y[0 .. usedy]);

}

@safe pure nothrow @nogc
private uint adjust_division_down(uint[] x, const uint[] y, ulong q)
{
    version(D_InlineAsm_X86)
    {
        enum pushes = 4;
        enum last_param = pushes * 4 + 4;
        enum qlo = last_param;
        enum qhi = last_param + 4 * 1;
        enum ylen = last_param + 4 * 2;
        enum yptr = last_param + 4 * 3;
        enum xlen = last_param + 4 * 4;
        enum xptr = last_param + 4 * 5;

        asm @safe pure nothrow @nogc
        {
            naked;
            push EBX;
            push ESI;
            push EDI;
            push EBP;
            xor EAX, EAX;
            mov ECX, dword ptr [ESP + ylen];
            test ECX, ECX;
            jz cleanup;
            mov ESI, dword ptr [ESP + yptr];
            lea ESI, [ESI + ECX * 4];
            mov EDI, dword ptr [ESP + xptr];
            lea EDI, [EDI + ECX * 4];
            neg ECX;
            xor EBX, EBX;
            xor EBP, EBP;
        adjust_loop:
            //carry in EBP:EBX
            mov EAX, dword ptr [ESI + ECX * 4];
            mul dword ptr [ESP + qlo];
            add EBX, EAX;
            adc EBP, EDX;
            xor EAX, EAX;
            sub dword ptr [EDI + ECX * 4], EBX;
            setc AL;
            mov EBX, EBP;      
            xor EBP, EBP;
            add EBX, EAX;
            adc EBP, 0;
            add ECX, 1;
            jnz adjust_loop;
            mov EAX, EBX;
        cleanup:
            pop EBP;
            pop EDI;
            pop ESI;
            pop EBX;
            ret 6 * 4;
        }
    }
    else
    {
        ulong carry = 0;
        for (size_t i = 0; i < y.length; ++i)
        {
            carry += y[i] * q;
            uint digit = cast(uint)carry;
            carry >>>= 32;
            if (x[i] < digit)
                ++carry;
            x[i] -= digit;
        }
        return cast(uint)carry;
    }
    
}

@safe pure nothrow @nogc
private uint adjust_division_up(uint[] x, const uint[] y)
{
    version (D_InlineAsm_X86)
    {
        enum pushes = 3;
        enum last_param = pushes * 4 + 4;
        enum ylen = last_param;
        enum yptr = last_param + 1 * 4;
        enum xlen = last_param + 2 * 4;
        enum xptr = last_param + 3 * 4;

        asm pure @safe nothrow @nogc
        {

            naked;
            push EDI;
            push ESI;
            xor EAX, EAX;
            mov ECX, dword ptr [ESP + ylen];
            test ECX, ECX;
            jz cleanup;
            mov ESI, dword ptr [ESP + yptr];
            mov EDI, dword ptr [ESP + xptr];
            lea ESI, [ESI + ECX * 4];
            lea EDI, [EDI + ECX * 4];
        adjust_loop:
            xor EDX, EDX;
            add EAX, dword ptr [ESI + ECX * 4];
            adc EDX, 0;
            add EAX, dword ptr [EDI + ECX * 4];
            adc EDX, 0;
            mov dword ptr [EDI + ECX * 4], EAX;
            mov EAX, EDX;
            add ECX, 1;
            jnz adjust_loop;
        cleanup:
            pop ESI;
            pop EDI;
            ret 4 * 4;
        }      
    }
    else 
    {
        ulong carry = 0;
        for (size_t i = 0; i < y.length; ++i)
        {
            carry += x[i];
            carry += y[i];
            x[i] = cast(uint)carry;
            carry >>= 32;
        }

        return cast(uint)carry;
    }
}

@safe pure nothrow @nogc
private size_t used_generic(const(uint)[] x)
{
    for (ptrdiff_t i = x.length - 1; i >= 0; --i)
    {
        if (x[i])
            return i + 1;
    }
    return 0;
}

///counts non zero elements
@safe pure nothrow @nogc
size_t used(const(uint)[] x)
{
    version(D_InlineAsm_X86)
    {
        if (__ctfe)
            return used_generic(x);

        enum pushes = 0;
        enum last_param = pushes * 4 + 4;
        enum xlen = last_param + 0 * 4;
        enum xptr = last_param + 1 * 4;

        asm @safe pure nothrow @nogc
        {
            naked;
            mov ECX, dword ptr [ESP + xlen];
            test ECX, ECX;
            jz zero;
            mov EDX, dword ptr [ESP + xptr];
            sub EDX, 4;
        used_loop:
            mov EAX, dword ptr [EDX + ECX * 4];
            test EAX, EAX;
            jnz not_zero;
            sub ECX, 1;
            jnz used_loop;
        zero:
            xor EAX, EAX;
            jmp cleanup;
        not_zero:
            mov EAX, ECX;
        cleanup:
            ret 2 * 4;
        }
    }
    else
    {
        return used_generic(x);
    }
}


///returns true if x is a power f two
@safe pure nothrow @nogc
uint ispow2(const(uint)[] x)
{
    assert(x.length >= 2);
    return ispow2(x[$ - 1]) && all(x[0 .. $ - 1], ZERO_BITS);
}

///returns leading zeros of x
@safe pure nothrow @nogc
auto clz(const(uint)[] x)
{
    for (ptrdiff_t i = x.length - 1; i >= 0; --i)
        if (x[i])
            return i * 32 + clz(x[i]);
    return x.length * 32;
}

///returns trailing zeros of x
@safe pure nothrow @nogc
auto ctz(const(uint)[] x)
{
    for (size_t i = 0; i < x.length; ++i)
        if (x[i])
            return ctz(x[i]) + i * 32;
    return x.length * 32;
}

@safe pure nothrow @nogc
uint hash(const(uint)[] x)
{
    if (x.length == 0)
        return 0;
    uint ret = x[0];
    for (size_t i = 1; i < x.length; ++i)
        ret ^= x[i];
    return ret;
}





