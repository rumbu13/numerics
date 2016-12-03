module numerics.internal.strings;

import std.traits: isSomeChar, isSomeString;
import std.range.primitives : isInputRange, ElementType;

enum Header
{
    none        = 0,
    plus        = 1,
    minus       = 2,
    hex         = 4,
    oct         = 8,
    bin         = 16,
    zero        = 32,
    any         = plus | minus | hex | oct | bin,
}

///detects a string header
@safe pure nothrow @nogc
Header detect(S)(const Header expected, auto const ref S s, ref size_t index) if (isSomeString!S)
{
    if (index < s.length)
    {
        if (expected & Header.plus)
        {
            if (s[index] == '+')
            {
                ++index;
                return Header.plus;
            }
        }

        if (expected & Header.minus)
        {
            if (s[index] == '-')
            {
                ++index;
                return Header.minus;
            }
        }

        if (expected & (Header.hex | Header.bin | Header.oct))
        {
            if (s[index] == '0')
            {
                ++index;

                if (expected & Header.hex)
                {
                    if (index < s.length && (s[index] == 'x' || s[index] == 'X'))
                    {
                        ++index;
                        return Header.hex;
                    }
                }

                if (expected & Header.bin)
                {
                    if (index < s.length && (s[index] == 'b' || s[index] == 'B'))
                    {
                        ++index;
                        return Header.bin;
                    }
                }

                if (expected & Header.oct)
                {
                    if (index < s.length && (s[index] == 'o' || s[index] == 'O'))
                    {
                        ++index;
                        return Header.oct;
                    }
                }

                --index;
            }
        }   
    } 
    return Header.none;
}



