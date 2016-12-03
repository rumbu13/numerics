module numerics.internal.chars;

import std.traits: isSomeChar;
import std.array;

@safe pure nothrow @nogc
C digitToChar2(C)(const uint digit, const bool uppercase = true) if (isSomeChar!C)
{
    if (digit < 10)
        return cast(C)('0' + digit);
    else
        return cast(C)((uppercase ? 'A' : 'a') + digit - 10);
}

@safe pure nothrow @nogc
C digitToChar(C)(const uint digit, const bool uppercase = true) if (isSomeChar!C)
{
    enum lo = "0123456789abcdefghijklmnopqrstuvwxyz";
    enum up = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    return uppercase ? up[digit] : lo[digit]; 
}

@safe pure nothrow @nogc
int charToDigit(C)(const C c, const uint radix) if (isSomeChar!C)
{
    if (radix <= 10)
        return c >= '0' && c <= '0' + radix - 1 ? c - '0' : -1;
    else
    {
        if (c >= '0' && c <= '9')
            return c - '0';
        if (c >= 'A' && c <= 'A' + radix - 11)
            return c - 'A' + 10;
        if (c >= 'a' && c <= 'a' + radix - 11)
            return c - 'a' + 10;
    }
    return -1;
}

struct BufferedRange(C, size_t size)
{

    pure @safe nothrow @nogc:

    ptrdiff_t lo = -1, hi = -1;
    Unqual!C[size] buffer = void;
    @property bool empty() { return hi < lo; }
    @property C front() { return buffer[lo]; }
    @property C back() { return buffer[hi]; }
    void popFront() { ++lo; }
    void popBack() { --hi; }

}


