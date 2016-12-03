module numerics.internal.floats;

import numerics.internal.integrals: clz;

private union FU
{
    float f;
    uint u;
}

///packs a float value
@safe pure nothrow @nogc
float fpack(const bool sign, int exp, uint mantissa)
{
    if (mantissa == 0)
        return sign ? -0.0f : +0.0f;
    auto shift = clz(mantissa) - 8;
    if (shift < 0)
    {
        if (exp > int.max + shift)
            return sign ? -float.infinity : +float.infinity;
        else       
            mantissa >>= -shift;
    }
    else
    {
        if (exp < int.min + shift)
            return sign ? -0.0f : +0.0f;
        mantissa <<= shift;
    }
    exp -= shift;

    if (exp > int.max - 150)
        return sign ? -float.infinity : +float.infinity;
    exp += 150;

    if (exp >= 0xFF)
        return sign ? -float.infinity : +float.infinity;

    if (exp <= 0)
    {
        --exp;
        if (exp < -23)
            return sign ? -0.0f : +0.0f;
        mantissa >>= -exp;
        exp = 0;
    }

    FU fu;
    fu.u = (mantissa & 0x7FFFFF) | (exp << 23);
    if (sign)
        fu.u |= 0x80000000U;
    return fu.f;
}

///unpacks a float value
@safe pure nothrow @nogc
bool funpack(const float f, out int exp, out uint mantissa, out bool inf, out bool nan)
{
    FU fu;
    fu.f = f;

    exp = (fu.u >> 23) & 0xFF;
    mantissa = fu.u & 0x7FFFFFU;
    if (exp == 0)
    {
        inf = false; nan = false;
        if (mantissa)
            exp -= 149;
    }
    else if (exp == 0xFF)
    {
        inf = mantissa == 0;
        nan = !inf;
    }
    else
    {
        inf = false; nan = false;
        mantissa |= 0x1000000U;
        exp -= 150;
    }

    return (fu.u & 0x80000000U) != 0;
}


private union DU
{
    double d;
    ulong u;
}

///packs a double value
@safe pure nothrow @nogc
double dpack(const bool sign, int exp, ulong mantissa)
{
    if (mantissa == 0)
        return sign ? -0.0 : +0.0;

    auto shift = clz(mantissa) - 11;
    if (shift < 0)
    {
        if (exp > int.max + shift)
            return sign ? -double.infinity : +double.infinity;
        else       
            mantissa >>= -shift;
    }
    else
    {
        if (exp < int.min + shift)
            return sign ? -0.0 : +0.0;
        mantissa <<= shift;
    }
    exp -= shift;

    if (exp > int.max - 1075)
        return sign ? -double.infinity : +double.infinity;
    exp += 1075;

    if (exp >= 0x7FF)
        return sign ? -double.infinity : +double.infinity;

    if (exp <= 0)
    {
        --exp;
        if (exp < -52)
            return sign ? -0.0 : +0.0;
        mantissa >>= -exp;
        exp = 0;
    }

    DU du;
    du.u = (mantissa & 0x000FFFFFFFFFFFFFUL) | (cast(ulong)exp << 52);
    if (sign)
        du.u |= 0x8000000000000000UL;
    return du.d;
}

///unpacks a double value
@safe pure nothrow @nogc
bool dunpack(const double d, out int exp, out ulong mantissa, out bool inf, out bool nan)
{
    DU du;
    du.d = d;

    exp = (du.u >> 52) & 0x7FF;
    mantissa = du.u & 0xFFFFFFFFFFFFF;

    if (exp == 0)
    {
        inf = false; nan = false;
        if (mantissa)
            exp -= 1074;
    }
    else if (exp == 0x7FF)
    {
        inf = mantissa == 0;
        nan = !inf;
    }
    else
    {
        inf = false; nan = false;
        mantissa |= 0x10000000000000;
        exp -= 1075;
    }

    return (du.u & 0x8000000000000000UL) != 0;
}

private union RU
{
    real r;
    struct
    {   align(1):
        ushort e;
        ulong m;
    }
}

///packs a real80 value
@safe pure nothrow @nogc
real rpack(const bool sign, int exp, ulong mantissa)
{
    if (mantissa == 0)
        return sign ? -0.0L : +0.0L;

    auto shift = clz(mantissa);
    if (exp < int.min + shift)
        return sign ? -0.0L : +0.0L;
    mantissa <<= shift;
    exp -= shift;

    if (exp > int.max - 16447) //16383 + 64
        return sign ? -real.infinity : +real.infinity;
    exp += 16447;

    if (exp >= 0x7FFF)
        return sign ? -real.infinity : +real.infinity;

    if (exp <= 0)
    {
        --exp;
        if (exp < -64)
            return sign ? -0.0L : +0.0L;
        mantissa >>= -exp;
        exp = 0;
    }

    RU ru;
    ru.m = mantissa;
    ru.e = cast(ushort)exp;
    if (sign)
        ru.e |= 0x8000U;
    return ru.r;
}


///unpacks a real80 value
@safe pure nothrow @nogc
bool runpack(const real r, out int exp, out ulong mantissa, out bool inf, out bool nan)
{
    RU ru;
    ru.r = r;

    exp = ru.e & 0x7FFF;
    mantissa = ru.m;

    if (exp == 0)
    {
        inf = false; nan = false;
        if (mantissa)
            exp -= 16446;
    }
    else if (exp == 0x7FFF)
    {
        inf = mantissa == 0;
        nan = !inf;
    }
    else
    {
        inf = false; nan = false;
        exp -= 16447;
    }

    return (ru.e & 0x8000) != 0;
}
