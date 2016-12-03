module mixins;

import std.datetime;
import std.random;
import std.format;

string arrayVar(uint bits)
{
    return format("arrays%d", bits);
}

string genArrayTypes(uint minBits, uint maxBits)
{
    string s;
    for (uint bits = minBits; bits <= maxBits; bits += 32)
        s ~= format("alias A%d = uint[%d];\n", bits, bits / 32);
    return s;
}

string genArrayVariables(uint minBits, uint maxBits, uint samples)
{
    string s;
    for (uint bits = minBits; bits <= maxBits; bits += 32)
        s ~= format("A%d[%d] arrays%d;\n", bits, samples, bits);
    return s;
}

void randomizeArray(uint[] arr)
{
    for (size_t i = 0; i < arr.length; ++i)
        arr[i] = uniform!uint();
}

string genRandomizeArrays(uint minBits, uint maxBits, uint samples)
{
    string s;
    for (uint bits = minBits; bits <= maxBits; bits += 32)
    {
        s ~= format("for (size_t i = 0; i < %d; ++i)\n", samples);
        s ~= format("  randomizeArray(arrays%d[i]);\n", bits);
    }
    return s;
}

pragma(msg, genRandomizeArrays(96, 256, 100));