import std.stdio;
import std.typetuple;
import std.datetime;
import std.typecons;
import numerics.internal.arrays;
import numerics.fixed;
import std.format;
import std.typetuple;
import std.random;
import std.range;
import data;


int main(string[] argv)
{


    writeln("Press any key to continue.");
    getchar();
    return 0;
}

unittest
{
    writeln("all test");

    struct mt { uint[] initial; uint val; bool expected; }

    auto values = [
        mt([],          1, true),
        mt([42],        42, true),
        mt([42],        43, false),
        mt([42, 42],    42, true),
        mt([42, 43],    42, false),
        mt([43, 42],    42, false),
        mt([42, 42],    43, false),
    ];

    foreach(v; values)
    {
        assert(all(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("used test");

    struct mt { uint[] initial; size_t expected; }

    auto values = [
        mt([],           0),
        mt([0],          0),
        mt([1],          1),
        mt([1, 1],       2),
        mt([1, 0],       1),
        mt([0, 1],       2),
    ];

    foreach(v; values)
    {
        assert(used(v.initial) == v.expected);
    }
}

unittest
{
    writeln("mov uint test");

    struct mt { uint[] initial; uint val; uint[] expected; }

    auto values = [
        mt([1],                75, [75]),
        mt([1, 2],             77, [77, 0]),
    ];

    foreach(v; values)
    {
        mov(v.initial, v.val);
        assert(v.initial[] == v.expected[]);
    }
}


unittest
{
    writeln("movs int test");

    struct mt { uint[] initial; int val; uint[] expected; }

    auto values = [
        mt([1],                 75, [75]),
        mt([1],                -75, [-75]),
        mt([1, 2],              23, [23, 0]),
        mt([1, 2],             -23, [-23, uint.max]),
    ];

    foreach(v; values)
    {
        movs(v.initial, v.val);
        assert(v.initial[] == v.expected[]);
    }
}

unittest
{
    writeln("mov ulong test");

    struct mt { uint[] initial; ulong val; uint[] expected; }

    auto values = [
        mt([1, 2],             0xABCD_EF01_2345_6789, [0x2345_6789, 0xABCD_EF01]),
        mt([1, 2, 3],          0x1234_5678_90AB_CDEF, [0x90AB_CDEF, 0x1234_5678, 0]),
    ];

    foreach(v; values)
    {
        mov(v.initial, v.val);
        assert(v.initial[] == v.expected[]);
    }
}

unittest
{
    writeln("movs long test");

    struct mt { uint[] initial; ulong val; uint[] expected; }

    auto values = [
        mt([1, 2],             0xABCD_EF01_2345_6789, [0x2345_6789, 0xABCD_EF01]),
        mt([1, 2],             0x8BCD_EF01_2345_6789, [0x2345_6789, 0x8BCD_EF01]),
        mt([1, 2, 3],          0x1111_2222_3333_4444, [0x3333_4444, 0x1111_2222, 0]),
        mt([1, 2, 3],          0x8234_5678_90AB_CDEF, [0x90AB_CDEF, 0x8234_5678, uint.max]),
    ];

    foreach(v; values)
    {
        movs(v.initial, v.val);
        assert(v.initial[] == v.expected[]);
    }
}

unittest
{
    writeln("mov array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([1],              [],      [0]),
        mt([1],              [75],    [75]),
        mt([1, 2],           [23],    [23, 0]),
    ];

    foreach(v; values)
    {
        mov(v.initial, v.val);
        assert(v.initial[] == v.expected[]);
    }
}

unittest
{
    writeln("movs array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([1],                 [],         [0]),
        mt([1],                 [75],       [75]),
        mt([1],                 [-75],      [-75]),
        mt([1, 2],              [24],       [24, 0]),
        mt([1, 2],              [-24],      [-24, uint.max]),
    ];

    foreach(v; values)
    {
        movs(v.initial, v.val);
        assert(v.initial[] == v.expected[]);
    }
}

unittest
{
    writeln("equuu uint test");

    struct mt { uint[] initial; uint val; bool expected; }

    auto values = [
        mt([],                 0, true),
        mt([],                 1, false),
        mt([1],                1, true),
        mt([2],                1, false),
        mt([1, 0],             1, true),
        mt([1, 1],             1, false),
        mt([0, 1],             1, false),
    ];

    foreach(v; values)
    {
        assert(equuu(v.initial, v.val) == v.expected);
    }
}


unittest
{
    writeln("equuu ulong test");

    struct mt { uint[] initial; ulong val; bool expected; }

    auto values = [
        mt([],                              0, true),
        mt([],                              1, false),
        mt([1],                             1, true),
        mt([2],                             1, false),
        mt([1, 0],                          1, true),
        mt([1, 1],                          1, false),
        mt([0, 1],                          1, false),
        mt([1, 0, 0],                       1, true),
        mt([0, 1, 0],                       1, false),
        mt([0, 0, 1],                       1, false),
        mt([0x2345_6789, 0xABCD_EF01],      0xABCD_EF01_2345_6789, true),
        mt([0x2345_6789, 0xABCD_EF01],      0xABCD_EF01_2345_6788, false),
        mt([0x2345_6789, 0xABCD_EF01, 0],   0xABCD_EF01_2345_6789, true),
        mt([0x2345_6789, 0xABCD_EF01, 1],   0xABCD_EF01_2345_6788, false),
    ];

    foreach(v; values)
    {
        assert(equuu(v.initial, v.val) == v.expected);
    }
}


unittest
{
    writeln("equuu array test");

    struct mt { uint[] initial; uint[] val; bool expected; }

    auto values = [
        mt([],                 [], true),
        mt([],                 [0], true),
        mt([0],                [], true),
        mt([],                 [1], false),
        mt([1],                [], false),

        mt([1],                [1], true),
        mt([1],                [0], false),
        mt([0],                [1], false),
        mt([1],                [1, 0], true),
        mt([1, 0],             [1], true),
        mt([1],                [1, 1], false),
        mt([1, 1],             [1], false),
    ];

    foreach(v; values)
    {
        assert(equuu(v.initial, v.val) == v.expected);
        assert(equuu(v.val, v.initial) == v.expected);
    }
}

unittest
{
    writeln("equss int test");

    struct mt { uint[] initial; int val; bool expected; }

    auto values = [
        mt([],                 0, true),
        mt([],                 1, false),
        mt([1],                1, true),
        mt([2],                1, false),
        mt([1, 0],             1, true),
        mt([1, 1],             1, false),
        mt([0, 1],             1, false),
        mt([],                 -1, false),
        mt([-1],               -1, true),
        mt([-1],               1, false),
        mt([1],                -1, false),
        mt([-1, uint.max],     -1, true),
        mt([-1, 0],            -1, false),
    ];

    foreach(v; values)
    {
        assert(equss(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("equss long test");

    struct mt { uint[] initial; long val; bool expected; }

    auto values = [
        mt([],                 0, true),
        mt([],                 1, false),
        mt([1],                1, true),
        mt([2],                1, false),
        mt([1, 0],             1, true),
        mt([1, 1],             1, false),
        mt([0, 1],             1, false),
        mt([],                 -1, false),
        mt([-1],               -1, true),
        mt([-1],               1, false),
        mt([1],                -1, false),
        mt([-1, uint.max],     -1, true),
        mt([-1, 0],            -1, false),
    ];

    foreach(v; values)
    {
        assert(equss(v.initial, v.val) == v.expected);
    }
}


unittest
{
    writeln("equss array test");

    struct mt { uint[] initial; uint[] val; bool expected; }

    auto values = [
        mt([1],                [1], true),
        mt([1],                [-1], false),
        mt([-1],               [1], false),
        mt([-1],               [-1], true),
        mt([1, 2],             [1, -2], false),
        mt([1, 2, 3],          [1, 2, -3], false),
        mt([1, 0, 0, 0],       [1, 0], true),
        mt([-1, 0, 0, 0],      [0, 0, -1], false),
        mt([-1, uint.max],     [-1, uint.max, uint.max], true),
        mt([0, 0, 0, 1],       [0, 1, 0 -1], false),  
    ];

    foreach(v; values)
    {
        assert(equss(v.initial, v.val) == v.expected);
        assert(equss(v.val, v.initial) == v.expected);
    }
}

unittest
{
    writeln("equus int test");

    struct mt { uint[] initial; int val; bool expected; }

    auto values = [
        mt([1],               1, true),
        mt([1],               -1, false),
    ];

    foreach(v; values)
    {
        assert(equus(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("equus long test");

    struct mt { uint[] initial; long val; bool expected; }

    auto values = [
        mt([1],               1, true),
        mt([1],               -1, false),
    ];

    foreach(v; values)
    {
        assert(equus(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("equus array test");

    struct mt { uint[] initial; uint[] val; bool expected; }

    auto values = [
        mt([1],               [1], true),
        mt([1],               [-1], false),
    ];

    foreach(v; values)
    {
        assert(equus(v.initial, v.val) == v.expected);
        assert(equus(v.val, v.initial) == v.expected);
    }
}

unittest
{
    writeln("equsu uint test");

    struct mt { uint[] initial; uint val; bool expected; }

    auto values = [
        mt([1],               1, true),
        mt([-1],              1, false),
        mt([-1],              uint.max, false),
    ];

    foreach(v; values)
    {
        assert(equsu(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("equsu ulong test");

    struct mt { uint[] initial; ulong val; bool expected; }

    auto values = [
        mt([1],               1, true),
        mt([-1],              1, false),
        mt([-1],              ulong.max, false),
    ];

    foreach(v; values)
    {
        assert(equsu(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("equsu array test");

    struct mt { uint[] initial; uint[] val; bool expected; }

    auto values = [
        mt([1],               [1], true),
        mt([-1],              [1], false),
        mt([-1],              [uint.max], false),
    ];

    foreach(v; values)
    {
        assert(equsu(v.initial, v.val) == v.expected);
        assert(equsu(v.val, v.initial) == v.expected);
    }
}

unittest
{
    writeln("cmpuu uint test");

    struct mt { uint[] initial; uint val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([0, 0],           0, 0),
        mt([1, 0],           0, 1),
        mt([0, 1],           0, 1),
        mt([1, 1],           0, 1),
        mt([0, 0],           1, -1),
        mt([1, 0],           1, 0),
        mt([0, 1],           1, 1),
        mt([1, 1],           1, 1),
    ];

    foreach(v; values)
    {
        assert(cmpuu(v.initial, v.val) == v.expected);
    }
    ulong c = 0;
    auto z = cmpuu([0, 1], c);
}

unittest
{
    writeln("cmpuu ulong test");

    struct mt { uint[] initial; ulong val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([0, 0],           0, 0),
        mt([1, 0],           0, 1),
        mt([0, 1],           0, 1),
        mt([1, 1],           0, 1),
        mt([0, 0],           1, -1),
        mt([1, 0],           1, 0),
        mt([0, 1],           1, 1),
        mt([1, 1],           1, 1),
        mt([0, 0],           0x0000_0000_0000_0001UL, -1),
        mt([0, 0],           0x0000_0001_0000_0000UL, -1),
        mt([0, 0],           0x0000_0001_0000_0001UL, -1),
        mt([1, 0],           0x0000_0000_0000_0001UL, 0),
        mt([1, 0],           0x0000_0001_0000_0000UL, -1),
        mt([1, 0],           0x0000_0001_0000_0001UL, -1),
        mt([0, 1],           0x0000_0000_0000_0001UL, 1),
        mt([0, 1],           0x0000_0001_0000_0000UL, 0),
        mt([0, 1],           0x0000_0001_0000_0001UL, -1),
        mt([1, 1],           0x0000_0000_0000_0001UL, 1),
        mt([1, 1],           0x0000_0001_0000_0000UL, 1),
        mt([1, 1],           0x0000_0001_0000_0001UL, 0),
        mt([0, 0, 0],        0, 0),
        mt([0, 0, 0],        1, -1),
        mt([0, 0, 0],        0x0000_0001_0000_0000UL, -1),
        mt([0, 0, 0],        0x0000_0001_0000_0001UL, -1),
        mt([1, 0, 0],        0, 1),
        mt([1, 0, 0],        1, 0),
        mt([1, 0, 0],        0x0000_0001_0000_0000UL, -1),
        mt([1, 0, 0],        0x0000_0001_0000_0001UL, -1),
        mt([0, 1, 0],        0, 1),
        mt([0, 1, 0],        1, 1),
        mt([0, 1, 0],        0x0000_0001_0000_0000UL, 0),
        mt([0, 1, 0],        0x0000_0001_0000_0001UL, -1),
        mt([0, 0, 1],        0, 1),
        mt([0, 0, 1],        1, 1),
        mt([0, 0, 1],        0x0000_0001_0000_0000UL, 1),
        mt([0, 0, 1],        0x0000_0001_0000_0001UL, 1),
        mt([1, 1, 0],        0, 1),
        mt([1, 1, 0],        1, 1),
        mt([1, 1, 0],        0x0000_0001_0000_0000UL, 1),
        mt([1, 1, 0],        0x0000_0001_0000_0001UL, 0),
        mt([1, 0, 1],        0, 1),
        mt([1, 0, 1],        1, 1),
        mt([1, 0, 1],        0x0000_0001_0000_0000UL, 1),
        mt([1, 0, 1],        0x0000_0001_0000_0001UL, 1),
        mt([1, 1, 1],        0, 1),
        mt([1, 1, 1],        1, 1),
        mt([1, 1, 1],        0x0000_0001_0000_0000UL, 1),
        mt([1, 1, 1],        0x0000_0001_0000_0001UL, 1),
    ];

    foreach(v; values)
    {
        assert(cmpuu(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("cmpuu array test");

    struct mt { uint[] initial; uint[] val; int expected; }

    auto values = [
        mt([],               [], 0),
        mt([],               [0], 0),
        mt([],               [1], -1),
        mt([],               [0, 0], 0),
        mt([],               [0, 1], -1),
        mt([],               [1, 0], -1),
        mt([],               [1, 1], -1),
        mt([0],              [], 0),
        mt([0],              [0], 0),
        mt([0],              [1], -1),
        mt([0],              [0, 0], 0),
        mt([0],              [0, 1], -1),
        mt([0],              [1, 0], -1),
        mt([0],              [1, 1], -1),
        mt([1],              [], 1),
        mt([1],              [0], 1),
        mt([1],              [1], 0),
        mt([1],              [0, 0], 1),
        mt([1],              [0, 1], -1),
        mt([1],              [1, 0], 0),
        mt([1],              [1, 1], -1),
        mt([0, 0],           [], 0),
        mt([0, 0],           [0], 0),
        mt([0, 0],           [1], -1),
        mt([0, 0],           [0, 0], 0),
        mt([0, 0],           [0, 1], -1),
        mt([0, 0],           [1, 0], -1),
        mt([0, 0],           [1, 1], -1),
        mt([1, 0],           [], 1),
        mt([1, 0],           [0], 1),
        mt([1, 0],           [1], 0),
        mt([1, 0],           [0, 0], 1),
        mt([1, 0],           [0, 1], -1),
        mt([1, 0],           [1, 0], 0),
        mt([1, 0],           [1, 1], -1),
        mt([0, 1],           [], 1),
        mt([0, 1],           [0], 1),
        mt([0, 1],           [1], 1),
        mt([0, 1],           [0, 0], 1),
        mt([0, 1],           [0, 1], 0),
        mt([0, 1],           [1, 0], 1),
        mt([0, 1],           [1, 1], -1),
        mt([1, 1],           [], 1),
        mt([1, 1],           [0], 1),
        mt([1, 1],           [1], 1),
        mt([1, 1],           [0, 0], 1),
        mt([1, 1],           [0, 1], 1),
        mt([1, 1],           [1, 0], 1),
        mt([1, 1],           [1, 1], 0),
    ];

    foreach(v; values)
    {
        assert(cmpuu(v.initial, v.val) == v.expected);
        assert(cmpuu(v.val, v.initial) == -v.expected);
    }
}

unittest
{
    writeln("cmpss int test");

    struct mt { uint[] initial; int val; int expected; }

    auto values = [
        mt([0, -1],          -1, -1),
        mt([],               0, 0),
        mt([],               1, -1),
        mt([],               -1, 1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([0],              -1, 1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([1],              -1, 1),
        mt([-1],             0, -1),
        mt([-1],             1, -1),
        mt([-1],             -1, 0),
        mt([0, 0],           0, 0),
        mt([0, 0],           1, -1),
        mt([0, 0],           -1, 1),
        mt([1, 0],           0, 1),
        mt([1, 0],           1, 0),
        mt([1, 0],           -1, 1),
        mt([0, 1],           0, 1),
        mt([0, 1],           1, 1),
        mt([0, 1],           -1, 1),
        mt([1, 1],           0, 1),
        mt([1, 1],           1, 1),
        mt([1, 1],           -1, 1),
        mt([-1, 0],          0, 1),
        mt([-1, 0],          1, 1),
        mt([-1, 0],          -1, 1),
        mt([-1, 1],          0, 1),
        mt([-1, 1],          1, 1),
        mt([-1, 1],          -1, 1),
        mt([-1, -1],         0, -1),
        mt([-1, -1],         1, -1),
        mt([-1, -1],         -1, 0),
        mt([0, -1],          0, -1),
        mt([0, -1],          1, -1),
        
    ];

    foreach(v; values)
    {
        assert(cmpss(v.initial, v.val) == v.expected);
    }
   
}

unittest
{
    writeln("cmpss long test");

    struct mt { uint[] initial; long val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([],               -1, 1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([0],              -1, 1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([1],              -1, 1),
        mt([-1],             0, -1),
        mt([-1],             1, -1),
        mt([-1],             -1, 0),
        mt([0, 0],           0, 0),
        mt([0, 0],           1, -1),
        mt([0, 0],           -1, 1),
        mt([1, 0],           0, 1),
        mt([1, 0],           1, 0),
        mt([1, 0],           -1, 1),
        mt([0, 1],           0, 1),
        mt([0, 1],           1, 1),
        mt([0, 1],           -1, 1),
        mt([1, 1],           0, 1),
        mt([1, 1],           1, 1),
        mt([1, 1],           -1, 1),
        mt([-1, 0],          0, 1),
        mt([-1, 0],          1, 1),
        mt([-1, 0],          -1, 1),
        mt([-1, 1],          0, 1),
        mt([-1, 1],          1, 1),
        mt([-1, 1],          -1, 1),
        mt([-1, -1],         0, -1),
        mt([-1, -1],         1, -1),
        mt([-1, -1],         -1, 0),
        mt([0, -1],          0, -1),
        mt([0, -1],          1, -1),
        mt([0, -1],          -1, -1),
        mt([],               0x0000_0000_0000_0001, -1),
        mt([],               0x0000_0001_0000_0001, -1),
        mt([],               0x8000_0000_0000_0001, 1),
        mt([],               0x8000_0001_0000_0001, 1),
        mt([0],              0x0000_0000_0000_0001, -1),
        mt([0],              0x0000_0001_0000_0001, -1),
        mt([0],              0x8000_0000_0000_0001, 1),
        mt([0],              0x8000_0001_0000_0001, 1),
        mt([1],              0x0000_0000_0000_0001, 0),
        mt([1],              0x0000_0001_0000_0001, -1),
        mt([1],              0x8000_0000_0000_0001, 1),
        mt([1],              0x8000_0001_0000_0001, 1),
        mt([-1],             0x0000_0000_0000_0001, -1),
        mt([-1],             0x0000_0001_0000_0001, -1),
        mt([-1],             0x8000_0000_0000_0001, 1),
        mt([-1],             0x8000_0001_0000_0001, 1),
        mt([0, 1],           0x0000_0000_0000_0001, 1),
        mt([0, 1],           0x0000_0001_0000_0001, -1),
        mt([0, 1],           0x8000_0000_0000_0001, 1),
        mt([0, 1],           0x8000_0001_0000_0001, 1),
        mt([0, -1],          0x0000_0000_0000_0001, -1),
        mt([0, -1],          0x0000_0001_0000_0001, -1),
        mt([0, -1],          0x8000_0000_0000_0001, 1),
        mt([0, -1],          0x8000_0001_0000_0001, 1),
    ];

    foreach(v; values)
    {
        assert(cmpss(v.initial, v.val) == v.expected);
    }

}

unittest
{
    writeln("cmpss array test");

    struct mt { uint[] initial; uint[] val; int expected; }

    auto values = [
       mt([],               [], 0),
       mt([],               [0], 0),
       mt([],               [1], -1),
       mt([],               [-1], 1),
       mt([0],              [], 0),
       mt([0],              [0], 0),
       mt([0],              [1], -1),
       mt([0],              [-1], 1),
       mt([1],              [], 1),
       mt([1],              [0], 1),
       mt([1],              [1], 0),
       mt([1],              [-1], 1),
       mt([-1],             [], -1),
       mt([-1],             [0], -1),
       mt([-1],             [1], -1),
       mt([-1],             [-1], 0),
       mt([0, 0],           [], 0),
       mt([0, 0],           [0], 0),
       mt([0, 0],           [1], -1),
       mt([0, 0],           [-1], 1),
       mt([0, -1],          [], -1),
       mt([0, -1],          [0], -1),
       mt([0, -1],          [1], -1),
       mt([0, -1],          [-1], -1),
    ];

    foreach(v; values)
    {
        assert(cmpss(v.initial, v.val) == v.expected);
        assert(cmpss(v.val, v.initial) == -v.expected);
    }

}

unittest
{
    writeln("cmpus int test");

    struct mt { uint[] initial; int val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([],               -1, 1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([0],              -1, 1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([1],              -1, 1),
    ];

    foreach(v; values)
    {
        assert(cmpus(v.initial, v.val) == v.expected);
    }

}

unittest
{
    writeln("cmpus long test");

    struct mt { uint[] initial; long val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([],               -1, 1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([0],              -1, 1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([1],              -1, 1),
    ];

    foreach(v; values)
    {
        assert(cmpus(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("cmpus array test");

    struct mt { uint[] initial; uint[] val; int expected; }

    auto values = [
        mt([1],               [1], 0),
        mt([1],               [-1], 1),
    ];

    foreach(v; values)
    {
        assert(cmpus(v.initial, v.val) == v.expected);
        assert(cmpsu(v.val, v.initial) == -v.expected);
    }
}

unittest
{
    writeln("cmpsu uint test");

    struct mt { uint[] initial; uint val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([-1],             0, -1),
        mt([-1],             1, -1),
    ];

    foreach(v; values)
    {
        assert(cmpsu(v.initial, v.val) == v.expected);
    }

}

unittest
{
    writeln("cmpsu ulong test");

    struct mt { uint[] initial; ulong val; int expected; }

    auto values = [
        mt([],               0, 0),
        mt([],               1, -1),
        mt([0],              0, 0),
        mt([0],              1, -1),
        mt([1],              0, 1),
        mt([1],              1, 0),
        mt([-1],             0, -1),
        mt([-1],             1, -1),
    ];

    foreach(v; values)
    {
        assert(cmpsu(v.initial, v.val) == v.expected);
    }
}

unittest
{
    writeln("cmpsu array test");

    struct mt { uint[] initial; uint[] val; int expected; }

    auto values = [
        mt([1],               [1], 0),
        mt([-1],              [1], -1),
    ];

    foreach(v; values)
    {
        assert(cmpsu(v.initial, v.val) == v.expected);
        assert(cmpus(v.val, v.initial) == -v.expected);
    }
}

unittest
{
    writeln("or uint test");

    struct mt { uint[] initial; uint val; uint[] expected; }

    auto values = [
        mt([0],               2, [2]),
        mt([1],               2, [3]),
        mt([0, 0],            2, [2, 0]),
        mt([0, 1],            2, [2, 1]),
        mt([1, 0],            2, [3, 0]),
        mt([1, 1],            2, [3, 1]),

    ];

    foreach(v; values)
    {
        or(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("or ulong test");

    struct mt { uint[] initial; ulong val; uint[] expected; }

    auto values = [
        mt([0, 0],            2, [2, 0]),
        mt([0, 1],            2, [2, 1]),
        mt([1, 0],            2, [3, 0]),
        mt([1, 1],            2, [3, 1]),
        mt([0, 0, 0],         2, [2, 0, 0]),
        mt([0, 0, 1],         2, [2, 0, 1]),
        mt([0, 1, 1],         2, [2, 1, 1]),
        mt([1, 0, 0],         2, [3, 0, 0]),
        mt([1, 0, 1],         2, [3, 0, 1]),
        mt([1, 1, 1],         2, [3, 1, 1]),
    ];

    foreach(v; values)
    {
        or(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("or array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([1],               [], [1]),
        mt([1],               [2], [3]),
        mt([1, 1],            [2], [3, 1]),
        mt([1, 1],            [2, 2], [3, 3]),
    ];

    foreach(v; values)
    {
        or(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("ors int test");

    struct mt { uint[] initial; int val; uint[] expected; }

    auto values = [
        mt([1],               2, [3]),
        mt([1],               -2, [-1]),
        mt([1, 1],            2, [3, 1]),
        mt([1, 1],            -2, [-1, -1]),
    ];

    foreach(v; values)
    {
        ors(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("ors long test");

    struct mt { uint[] initial; long val; uint[] expected; }

    auto values = [
        mt([1, 1],            2, [3, 1]),
        mt([1, 1],            -2, [-1, -1]),
        mt([1, 1, 1],         2, [3, 1, 1]),
        mt([1, 1, 1],         -2, [-1, -1, -1]),
    ];

    foreach(v; values)
    {
        ors(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("ors array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([1],               [], [1]),
        mt([1],               [2], [3]),
        mt([1, 1],            [2], [3, 1]),
        mt([1, 1],            [2, 2], [3, 3]),
        mt([1, 1],            [-2], [-1, -1]),
    ];

    foreach(v; values)
    {
        ors(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("and uint test");

    struct mt { uint[] initial; uint val; uint[] expected; }

    auto values = [
        mt([5],               3, [1]),
        mt([5, 5],            3, [1, 0]),
    ];

    foreach(v; values)
    {
        and(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("and ulong test");

    struct mt { uint[] initial; ulong val; uint[] expected; }

    auto values = [
        mt([5, 5],            3, [1, 0]),
        mt([5, 5, 5],         3, [1, 0, 0]),
    ];

    foreach(v; values)
    {
        and(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("and array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([],                [], []),
        mt([5],               [3], [1]),
        mt([5, 5],            [3], [1, 0]),
    ];

    foreach(v; values)
    {
        and(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("ands uint test");

    struct mt { uint[] initial; int val; uint[] expected; }

    auto values = [
        mt([5],               3, [1]),
        mt([5],               -3, [5]),
        mt([5, 5],            3, [1, 0]),
        mt([5, 5],            -3, [5, 5]),
    ];

    foreach(v; values)
    {
        ands(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("ands long test");

    struct mt { uint[] initial; long val; uint[] expected; }

    auto values = [
        mt([5, 5],            3, [1, 0]),
        mt([5, 5],            -3, [5, 5]),
        mt([5, 5, 5],          3, [1, 0, 0]),
        mt([5, 5, 5],         -3, [5, 5, 5]),
    ];

    foreach(v; values)
    {
        ands(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("ands array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([],                [], []),
        mt([5],               [], [0]),

    ];

    foreach(v; values)
    {
        ands(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("xor uint test");

    struct mt { uint[] initial; uint val; uint[] expected; }

    auto values = [
        mt([2],            3, [1]),
        mt([2, 0],         3, [1, 0]),
    ];

    foreach(v; values)
    {
        xor(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("xor ulong test");

    struct mt { uint[] initial; ulong val; uint[] expected; }

    auto values = [
        mt([2, 0],         3, [1, 0]),
        mt([2, 0, 0],      3, [1, 0, 0]),
    ];

    foreach(v; values)
    {
        xor(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("xor array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([2],               [], [2]),
        mt([2, 2],            [], [2, 2]),
        mt([2, 2],            [3], [1, 2]),
        mt([2, 2],            [3, 3], [1, 1]),
    ];

    foreach(v; values)
    {
        xor(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("xors int test");

    struct mt { uint[] initial; int val; uint[] expected; }

    auto values = [
        mt([2],               3, [1]),
        mt([2],               -3, [-1]),
        mt([2, 2],            3, [1, 2]),
        mt([2, 2],            -3, [-1, 0xFFFF_FFFD]),
    ];

    foreach(v; values)
    {
        xors(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("xors long test");

    struct mt { uint[] initial; long val; uint[] expected; }

    auto values = [
        mt([2, 2],            3, [1, 2]),
        mt([2, 2],            -3, [-1, 0xFFFF_FFFD]),
        mt([2, 2, 2],         3, [1, 2, 2]),
        mt([2, 2, 2],         -3, [-1, 0xFFFF_FFFD, 0xFFFF_FFFD]),
    ];

    foreach(v; values)
    {
        xors(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("xors array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; }

    auto values = [
        mt([2],               [], [2]),
        mt([2],               [3], [1]),
        mt([2, 2],            [3], [1, 2]),
        mt([2, 2],            [3, 3], [1, 1]),
        mt([2, 2],            [-3], [-1, 0xFFFF_FFFD]),
    ];

    foreach(v; values)
    {
        xors(v.initial, v.val);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("not test");

    struct mt { uint[] initial; uint[] expected; }

    auto values = [
        mt([],               []),
        mt([0],              [-1]),
        mt([0, 0],           [-1, -1]),
        mt([0, 0, 0],        [-1, -1, -1]),
    ];

    foreach(v; values)
    {
        not(v.initial);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("inc test");

    struct mt { uint[] initial; uint[] expected; uint carry; }

    auto values = [
        mt([],               [], 1),
        mt([0],              [1], 0),
        mt([-1],             [0], 1),
        mt([0, 0],           [1, 0], 0),
        mt([-1, 0],          [0, 1], 0),
        mt([-1, -1],         [0, 0], 1),
    ];

    foreach(v; values)
    {
        assert(inc(v.initial) == v.carry);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("dec test");

    struct mt { uint[] initial; uint[] expected; uint carry; }

    auto values = [
        mt([],               [], 1),
        mt([1],              [0], 0),
        mt([0],              [-1], 1),
        mt([1, 1],           [0, 1], 0),
        mt([0, 1],           [-1, 0], 0),
        mt([0, 0],           [-1, -1], 1),
    ];

    foreach(v; values)
    {
        assert(dec(v.initial) == v.carry);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("neg test");

    struct mt { uint[] initial; uint[] expected; }

    auto values = [
        mt([],               []),
        mt([-1],             [1]),
        mt([1],              [-1]),
        mt([0, -1],          [0, 1]),
        mt([-1, -1],         [1, 0]),
    ];

    foreach(v; values)
    {
        neg(v.initial);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("add uint test");

    struct mt { uint[] initial; uint val; uint[] expected; uint carry;}

    auto values = [
        mt([0],              0, [0], 0),
        mt([0],              1, [1], 0),
        mt([0],              2, [2], 0),
        mt([1],              0, [1], 0),
        mt([1],              1, [2], 0),
        mt([1],              2, [3], 0),
        mt([-1],             0, [-1], 0),
        mt([-1],             1, [0], 1),
        mt([-1],             2, [1], 1),
        mt([0, 0],           0, [0, 0], 0),
        mt([0, 0],           1, [1, 0], 0),
        mt([0, 0],           2, [2, 0], 0),
        mt([-1, 0],          0, [-1, 0], 0),
        mt([-1, 0],          1, [0, 1], 0),
        mt([-1, 0],          2, [1, 1], 0),
        mt([-1, -1],         0, [-1, -1], 0),
        mt([-1, -1],         1, [0, 0], 1),
        mt([-1, -1],         2, [1, 0], 1),
    ];

    foreach(v; values)
    {
        assert(add(v.initial, v.val) == v.carry);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("add ulong test");

    struct mt { uint[] initial; ulong val; uint[] expected; uint carry;}

    auto values = [
        mt([0, 0],           0, [0, 0], 0),
        mt([0, 0],           1, [1, 0], 0),
        mt([0, 0],           2, [2, 0], 0),
        mt([-1, 0],          0, [-1, 0], 0),
        mt([-1, 0],          1, [0, 1], 0),
        mt([-1, 0],          2, [1, 1], 0),
        mt([-1, -1],         0, [-1, -1], 0),
        mt([-1, -1],         1, [0, 0], 1),
        mt([-1, -1],         2, [1, 0], 1),
        mt([0, 0],           0x0000_0001_0000_0001, [1, 1], 0),
        mt([-1, 0],          0x0000_0001_0000_0001, [0, 2], 0),
        mt([-1, -1],         0x0000_0001_0000_0001, [0, 1], 1),
        mt([0, 0, 0],        0x0000_0001_0000_0001, [1, 1, 0], 0),
        mt([-1, 0, 0],       0x0000_0001_0000_0001, [0, 2, 0], 0),
        mt([-1, -1, 0],      0x0000_0001_0000_0001, [0, 1, 1], 0),
        mt([-1, -1, -1],     0x0000_0001_0000_0001, [0, 1, 0], 1),

    ];

    foreach(v; values)
    {
        assert(add(v.initial, v.val) == v.carry);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("add array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; uint carry; }

    auto values = [
        mt([], [], [], 0),
        mt([1], [2], [3], 0),
        mt([1, 2], [2], [3, 2], 0),
        mt([-1, 2], [1], [0, 3], 0),
        mt([-1, -1], [1], [0, 0], 1),
    ];

    foreach(v; values)
    {
        assert(add(v.initial, v.val) == v.carry);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("sub uint test");

    struct mt { uint[] initial; uint val; uint[] expected; uint borrow;}

    auto values = [
        mt([2],              0, [2], 0),
        mt([2],              1, [1], 0),
        mt([2],              2, [0], 0),
        mt([0],              0, [0], 0),
        mt([0],              1, [-1], 1),
        mt([0],              2, [-2], 1),
        mt([2, 1],           0, [2, 1], 0),
        mt([2, 1],           1, [1, 1], 0),
        mt([2, 1],           2, [0, 1], 0),
        mt([0, 1],           0, [0, 1], 0),
        mt([0, 1],           1, [-1, 0], 0),
        mt([0, 0],           0, [0, 0], 0),
        mt([0, 0],           1, [-1, -1], 1),
    ];

    foreach(v; values)
    {
        assert(sub(v.initial, v.val) == v.borrow);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("sub ulong test");

    struct mt { uint[] initial; ulong val; uint[] expected; uint borrow;}

    auto values = [
         
        mt([2, 1],           0, [2, 1], 0),
        mt([2, 1],           1, [1, 1], 0),
        mt([2, 1],           2, [0, 1], 0),
        mt([0, 1],           0, [0, 1], 0),
        mt([0, 1],           1, [-1, 0], 0),
        mt([0, 0],           0, [0, 0], 0),
        mt([0, 0],           1, [-1, -1], 1),   
        mt([1, 1],           0x0000_0001_0000_0001, [0, 0], 0),
        mt([0, 1],           0x0000_0001_0000_0001, [-1, -1], 1),
    ];

    foreach(v; values)
    {
        assert(sub(v.initial, v.val) == v.borrow);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("sub array test");

    struct mt { uint[] initial; uint[] val; uint[] expected; uint borrow; }

    auto values = [
        mt([], [], [], 0),
        mt([3], [2], [1], 0),
        mt([3, 3], [2], [1, 3], 0),
        mt([0, 2], [1], [-1, 1], 0),
        mt([0, 0], [1], [-1, -1], 1),
    ];

    foreach(v; values)
    {
        assert(sub(v.initial, v.val) == v.borrow);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("shl test");

    struct mt { uint[] initial; uint shift; uint[] expected; }

    auto values = [
        mt([1, 2, 3, 4], 32, [0, 1, 2, 3]),
        mt([1, 2, 3, 4], 64, [0, 0, 1, 2]),
        mt([1, 2, 3, 4], 96, [0, 0, 0, 1]),
        mt([1, 2], 32, [0, 1]),

        mt([1], 8, [1 << 8]),
        mt([0x1234_5678, 0x9ABC_DEF0], 4, [0x2345_6780, 0xABCD_EF01]),
        mt([0x1234_5678, 0x9ABC_DEF0], 36, [0, 0x2345_6780]),
    ];

    foreach(v; values)
    {
        shl(v.initial, v.shift);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("shr test");

    struct mt { uint[] initial; uint shift; uint[] expected; }

    auto values = [
        mt([1, 2, 3, 4], 32, [2, 3, 4, 0]),
        mt([1, 2, 3, 4], 64, [3, 4, 0, 0]),
        mt([1, 2, 3, 4], 96, [4, 0, 0, 0]),
        mt([1, 2], 32, [2, 0]),

        mt([0x1234_5678], 8, [0x1234_5678 >>> 8]),
        mt([0x1234_5678, 0x9ABC_DEF0], 4, [0x0123_4567, 0x09AB_CDEF]),
        mt([0x1234_5678, 0x9ABC_DEF0], 36, [0x09AB_CDEF, 0]),
    ];

    foreach(v; values)
    {
        shr(v.initial, v.shift);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("sahr test");

    struct mt { uint[] initial; uint shift; uint[] expected; }

    auto values = [
        mt([1, 2, 3, 4], 32, [2, 3, 4, 0]),
        mt([1, 2, 3, 4], 64, [3, 4, 0, 0]),
        mt([1, 2, 3, 4], 96, [4, 0, 0, 0]),
        mt([1, 2], 32, [2, 0]),

        mt([0x1234_5678], 8, [0x1234_5678 >> 8]),
        mt([0x8234_5678], 8, [0xFF82_3456]),
        mt([0x1234_5678, 0x7ABC_DEF0], 4, [0x0123_4567, 0x07AB_CDEF]),
        mt([0x1234_5678, 0x8ABC_DEF0], 4, [0x0123_4567, 0xF8AB_CDEF]),
        mt([0x1234_5678, 0x7ABC_DEF0], 36, [0x07AB_CDEF, 0]),
        mt([0x1234_5678, 0x8ABC_DEF0], 36, [0xF8AB_CDEF, 0xFFFF_FFFF]),
    ];

    foreach(v; values)
    {
        sahr(v.initial, v.shift);
        assert(v.initial == v.expected);
    }
}

unittest
{
    writeln("mul uint basecase test");

    struct mt { uint[] initial; uint multiplier; uint[] expected; uint carry; }

    auto values = [
        mt([], 0, [], 0),
        mt([], 1, [], 0),
        mt([], 2, [], 0),
        mt([], 3, [], 0),
        mt([0], 0, [0], 0),
        mt([0], 1, [0], 0),
        mt([0], 2, [0], 0),
        mt([0], 3, [0], 0),
        mt([1], 0, [0], 0),
        mt([1], 1, [1], 0),
        mt([1], 2, [2], 0),
        mt([1], 3, [3], 0),
        mt([2], 0, [0], 0),
        mt([2], 1, [2], 0),
        mt([2], 2, [4], 0),
        mt([2], 3, [6], 0),
        mt([3], 0, [0], 0),
        mt([3], 1, [3], 0),
        mt([3], 2, [6], 0),
        mt([3], 3, [9], 0),
        
    ];

    foreach(v; values)
    {
        auto x = v.initial.dup();
        assert(mul_basecase(x, v.multiplier) == v.carry);
        assert(x == v.expected);
        x = v.initial.dup();
        assert(mul(x, v.multiplier) == v.carry);
        assert(x == v.expected);
    }

    foreach(m; mul_uint_data)
    {
        auto left = m.left.dup();
        auto carry = mul_basecase(left, m.right);
        if (m.result.length > left.length)
        {
            assert(carry == m.result[$ - 1]);
            assert(left[] == m.result[0 .. $ - 1]);
        }
        else
        {
            assert(!carry);
            assert(left[] == m.result[]);
        }
    }

    foreach(m; mul_uint_data)
    {
        auto left = m.left.dup();
        auto carry = mul(left, m.right);
        if (m.result.length > left.length)
        {
            assert(carry == m.result[$ - 1]);
            assert(left[] == m.result[0 .. $ - 1]);
        }
        else
        {
            assert(!carry);
            assert(left[] == m.result[]);
        }
    }
}

//
//unittest
//{
//    writeln("mul uint shift test");
//
//     foreach(m; mul_uint_data)
//    {
//        auto left = m.left.dup();
//
//        uint carry;
//
//        switch(m.left.length)
//        {
//            case 1: carry = mul_shift!32(left, m.right); break;
//            case 2: carry = mul_shift!64(left, m.right); break;
//            case 3: carry = mul_shift!96(left, m.right); break;
//            case 4: carry = mul_shift!128(left, m.right); break;
//            default:
//                assert(0);
//        }
//
//        if (m.result.length > left.length)
//        {
//            assert(carry == m.result[$ - 1]);
//            assert(left[] == m.result[0 .. $ - 1]);
//        }
//        else
//        {
//            assert(!carry);
//            assert(left[] == m.result[]);
//        }
//    }
//}

unittest
{
    writeln("mul array test");
    
    foreach(m; mul_array_data)
    {
        auto ret = new uint[m.left.length + m.right.length];
        if (m.left.length >= m.right.length)
            mul(ret, m.left, m.right);
        else
            mul(ret, m.right, m.left);
        assert(equuu(ret, m.result));
    }
}

unittest
{
    writeln("mul array basecase test");

    foreach(m; mul_array_data)
    {
        auto ret = new uint[m.left.length + m.right.length];
        if (m.left.length >= m.right.length)
            mul_basecase(ret, m.left, m.right);
        else
            mul_basecase(ret, m.right, m.left);
        assert(equuu(ret, m.result));
    }
}



unittest
{
    writeln("squ array basecase test");

    foreach(m; mul_array_data)
    {
        auto retm = new uint[m.left.length * 2];
        auto rets = new uint[m.left.length * 2];
        
        mul_basecase(retm, m.left, m.left);
        squ_basecase(rets, m.left);
        
        assert(equuu(retm, rets));

        retm = new uint[m.right.length * 2];
        rets = new uint[m.right.length * 2];
        
        mul_basecase(retm, m.right, m.right);
        squ_basecase(rets, m.right);

        assert(equuu(retm, rets));
    }
}

unittest
{
    writeln("mul array test");

    foreach(m; mul_array_data)
    {
        auto ret = new uint[m.left.length + m.right.length];
        if (m.left.length >= m.right.length)
            mul(ret, m.left, m.right);
        else
            mul(ret, m.right, m.left);
        assert(equuu(ret, m.result));
    }
}

unittest
{
    writeln("squ array test");

    foreach(m; mul_array_data)
    {
        auto retm = new uint[m.left.length * 2];
        auto rets = new uint[m.left.length * 2];

        mul(retm, m.left, m.left);
        squ(rets, m.left);

        assert(equuu(retm, rets));

        retm = new uint[m.right.length * 2];
        rets = new uint[m.right.length * 2];

        mul(retm, m.right, m.right);
        squ(rets, m.right);

        assert(equuu(retm, rets));
    }
}


unittest
{
    writeln("divrem uint basecase test");

    foreach(m; div_uint_data)
    {
        auto left = m.left.dup();
        uint rem1 = divrem_basecase(left, m.right); 
        uint rem2 = rem_basecase(m.left, m.right);
        assert(equuu(left, m.result));
        assert(equuu(m.remainder, rem1));
        assert(equuu(m.remainder, rem2));
    }
}

unittest
{
    writeln("divrem uint test");

    foreach(m; div_uint_data)
    {
        auto left = m.left.dup();
        uint rem1 = divrem(left, m.right); 
        uint rem2 = rem(m.left, m.right);
        assert(equuu(left, m.result));
        assert(equuu(m.remainder, rem1));
        assert(equuu(m.remainder, rem2));
    }
}



unittest
{
    writeln("divrem array basecase test");

    foreach(m; div_array_data)
    {
        if (m.left.length >= m.right.length)
        {
            uint[] quo = new uint[m.left.length];
            uint[] rem = new uint[m.left.length];
            divrem_basecase(quo, rem, m.left, m.right); 
            assert(equuu(quo, m.result));
            assert(equuu(rem, m.remainder));
        }
    }
}

unittest
{
    writeln("divrem array test");

    foreach(m; div_array_data)
    {
        uint[] quo = new uint[m.left.length];
        uint[] rem = new uint[m.left.length];
        divrem(quo, rem, m.left, m.right); 
        assert(equuu(quo, m.result));
        assert(equuu(rem, m.remainder));
    }
}


version(unittest)
{
    enum maxBits = 128;
    
    string genTypes()
    {
        string s;
        for (uint i = 96; i <= maxBits; i += 32)
        {
            s ~= format("alias int%d = FixedInt!(%d, true);\n", i, i);
            s ~= format("alias uint%d = FixedInt!(%d, false);\n", i, i);
        }
        return s;
    }

    mixin(genTypes());

    string genTuples()
    {
        string s = "alias signedTypes = TypeTuple!(";
        string t = "alias unsignedTypes = TypeTuple!(";
        for (uint i = 96; i <= maxBits; i += 32)
        {
            s ~= format("int%d", i);
            t ~= format("uint%d", i);
            if (i != maxBits)
            {
                s ~= ", ";
                t ~= ", ";
            }
        }
        return s ~ ");\n" ~ t  ~ ");\n" ~ "alias allTypes = TypeTuple!(unsignedTypes, signedTypes);\n";
    }

    alias _unsigned = TypeTuple!(ubyte, ushort, uint, ulong);
    alias _signed   = TypeTuple!(byte, short, int, long);
    alias _all      = TypeTuple!(_unsigned, _signed);

    mixin(genTuples());

}


unittest 
{
    writeln("constructor bool test");
    foreach(T; allTypes)
    {
        assert(T(true));
        assert(!T(false));
    }
}

unittest 
{
    writeln("constructor char test");
    foreach(T; allTypes)
    {
        assert((T('a') == 'a'));
        assert(T(wchar('a')) == wchar('a'));
        assert(T(dchar('a')) == dchar('a'));
    }
}

unittest 
{
    writeln("constructor integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            assert((T(U(10)) == U(10)));
        }
    }

    foreach(T; signedTypes)
    {
        foreach(U; _signed)
        {
            assert((T(U(-10)) == U(-10)), T.stringof ~ U.stringof);
        }
    }
}


unittest 
{
    writeln("constructor fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            static if(U.sizeof <= T.sizeof)
            {
                assert(T(U(42)) == U(42));
            }             
        }
    }


    foreach(T; signedTypes)
    {
        foreach(U; signedTypes)
        {
            static if(U.sizeof <= T.sizeof)
            {
                assert(T(U(-42)) == U(-42));
            }             
        }
    }
}

unittest 
{
    writeln("assignment bool test");
    foreach(T; allTypes)
    {
        T t = true;
        assert(t);
        t = false;
        assert(!t);
    }
}

unittest 
{
    writeln("assignment char test");
    foreach(T; allTypes)
    {
        T t = 'a';
        assert(t == 'a');

        t = wchar('a');
        assert(t == wchar('a'));

        t = dchar('a');
        assert(t == dchar('a'));

    }
}

unittest 
{
    writeln("assignment integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            T t = U(10);
            assert(t == U(10));
        }
    }

    foreach(T; signedTypes)
    {
        foreach(U; _signed)
        {
            T t = U(-10);
            assert(t == U(-10));
        }
    }
}

unittest 
{
    writeln("assignment fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            static if(U.sizeof <= T.sizeof)
            {
                T t = U(10);
                assert(t == U(10));
            }
        }
    }

    foreach(T; signedTypes)
    {
        foreach(U; signedTypes)
        {
            static if(U.sizeof <= T.sizeof)
            {
                T t = U(-10);
                assert(t == U(-10));
            }
        }
    }
}

unittest 
{
    writeln("equality bool test");
    foreach(T; allTypes)
    {
        auto t = T(true);
        auto f = T(false);
        assert(t == true);
        assert(f == false);
    }
}

unittest 
{
    writeln("equality char test");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(char, wchar, dchar))
        {
            auto a = T(U('a'));
            auto b = T(U('b'));
           
            assert(a == U('a'));
            assert(a != U('b'));
            assert(b != U('a'));
            assert(b == U('b'));      
        }
    }
}

unittest 
{
    writeln("equality integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            auto ten = T(U(10));
            auto hun = T(U(100));
            
            assert(ten == U(10));
            assert(ten != U(100));
            assert(hun != U(10));
            assert(hun == U(100));  
        }
    }

    foreach(T; signedTypes)
    {
        foreach(U; _signed)
        {
            auto ten = T(U(-10));
            auto hun = T(U(-100));

            assert(ten == U(-10));
            assert(ten != U(-100));
            assert(hun != U(-10));
            assert(hun == U(-100));  
        }
    }
}

unittest 
{
    writeln("equality fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            auto ten = T(10);
            auto hun = T(100);

            assert(ten == U(10));
            assert(ten != U(100));
            assert(hun != U(10));
            assert(hun == U(100));  
        }
    }

    foreach(T; signedTypes)
    {
        foreach(U; signedTypes)
        {
            auto ten = T(-10);
            auto hun = T(-100);

            assert(ten == U(-10));
            assert(ten != U(-100));
            assert(hun != U(-10));
            assert(hun == U(-100));  
        }
    }
}

unittest 
{
    writeln("order bool test");
    foreach(T; allTypes)
    {
        auto t = T(true);
        auto f = T(false);
        assert(t >= true);
        assert(t > false);
        assert(f < true);
        assert(f <= false);
    }
}

unittest 
{
    writeln("order char test");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(char, wchar, dchar))
        {
            auto a = T(U('a'));
            auto b = T(U('b'));

            assert(a >= U('a'));
            assert(a < U('b'));
            assert(b > U('a'));
            assert(b <= U('b'));      
        }
    }
}

unittest 
{
    writeln("order integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            auto ten = T(U(10));
            auto hun = T(U(100));

            assert(ten >= U(10));
            assert(ten < U(100));
            assert(hun > U(10));
            assert(hun <= U(100));  
        }
    }


    foreach(T; signedTypes)
    {
        foreach(U; _signed)
        {
            auto ten = T(U(-10));
            auto hun = T(U(-100));
            assert(ten > U(-100));
            assert(ten >= U(-10));
            assert(ten > U(-100));
            assert(hun < U(-10));
            assert(hun <= U(-100));  
        }
    }
}

unittest 
{
    writeln("order fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            auto ten = T(10);
            auto hun = T(100);

            assert(ten >= U(10));
            assert(ten < U(100));
            assert(hun > U(10));
            assert(hun <= U(100));  
        }
    }


    foreach(T; signedTypes)
    {
        foreach(U; signedTypes)
        {
            auto ten = T(-10);
            auto hun = T(-100);
            assert(ten > U(-100));
            assert(ten >= U(-10));
            assert(ten > U(-100));
            assert(hun < U(-10));
            assert(hun <= U(-100));  
        }
    }
}

unittest 
{
    writeln("cast bool test");
    foreach(T; allTypes)
    {
        auto t = T(100);
        auto f = T(0);
        assert(t);
        assert(!f);
    }
}

unittest 
{
    writeln("cast char test");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(char, wchar, dchar))
        {
            assert(cast(U)(T(U('a'))) == U('a'));    
        }
    }
}

unittest 
{
    writeln("cast integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
           assert(cast(U)(T(U(10))) == U(10));  
        }
    }


    foreach(T; signedTypes)
    {
        foreach(U; _signed)
        {
            assert(cast(U)(T(U(-10))) == U(-10));  
        }
    }
}

unittest 
{
    writeln("cast fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            assert(cast(U)(T(10)) == U(10));  
        }
    }


    foreach(T; signedTypes)
    {
        foreach(U; signedTypes)
        {
            assert(cast(U)(T(-10)) == U(-10));  
        }
    }
}

unittest 
{
    writeln("unary + test");
    foreach(T; allTypes)
    {
        auto x = T(1000);
        assert(+x == x);
    }
}

unittest 
{
    writeln("unary - test");
    foreach(T; allTypes)
    {
        auto x = T(1000);
        auto y = -(-x);
        assert(x == y);
    }
}

unittest 
{
    writeln("unary ~ test");
    foreach(T; allTypes)
    {
        auto x = T(1000);
        auto y = ~(~x);
        assert(x == y);
    }
}

unittest 
{
    writeln("unary ++/-- test");
    foreach(T; allTypes)
    {
        auto x = T(1000);
        auto y = ++(--x);
        assert(x == y);
    }
}

unittest 
{
    writeln("unary ++/-- test");
    foreach(T; allTypes)
    {
        auto x = T(1000);
        auto y = ++(--x);
        assert(x == y);
    }
}

unittest 
{
    writeln("or bool test");
    foreach(T; allTypes)
    {
        auto x = T(0x10);
        assert((x | true) == 0x11);
        assert((x | false) == 0x10);
    }
}


unittest 
{
    writeln("or char test");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(char, wchar, dchar))
        {
            auto x = T(0x10);
            auto c = U(0x01);
            auto d = U(0x10);
            assert((x | c) == 0x11);
            assert((x | d) == 0x10);
        }

    }
}

unittest 
{
    writeln("or integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            auto x = T(0x10);
            auto c = U(0x01);
            auto d = U(0x10);
            assert((x | c) == 0x11);
            assert((x | d) == 0x10);
        }

        foreach(U; _signed)
        {
            auto x = T(0x10);
            auto c = U(-1);
            assert((x | c) == -1);
        }
    }
}

unittest 
{
    writeln("or fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            auto x = T(0x10);
            auto c = U(0x01);
            auto d = U(0x10);
            assert((x | c) == 0x11);
            assert((x | d) == 0x10);
        }

        foreach(U; signedTypes)
        {
            auto x = T(0x10);
            auto c = U(-1);
            assert((x | c) == -1);
        }
    }
}

unittest 
{
    writeln("and bool test");
    foreach(T; allTypes)
    {
        auto x = T(0x11);
        assert((x & true) == 0x01);
        assert((x & false) == 0x00);
    }
}


unittest 
{
    writeln("and char test");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(char, wchar, dchar))
        {
            auto x = T(0x11);
            auto c = U(0x01);
            auto d = U(0x10);
            assert((x & c) == 0x01);
            assert((x & d) == 0x10);
        }

    }
}

unittest 
{
    writeln("and integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            auto x = T(0x11);
            auto c = U(0x01);
            auto d = U(0x10);
            assert((x & c) == 0x01);
            assert((x & d) == 0x10);
        }

        foreach(U; _signed)
        {
            auto x = T(0x11);
            auto c = U(-1);
            assert((x & c) == 0x11);
        }
    }
}

unittest 
{
    writeln("and fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            auto x = T(0x11);
            auto c = U(0x01);
            auto d = U(0x10);
            assert((x & c) == 0x01);
            assert((x & d) == 0x10);
        }

        foreach(U; signedTypes)
        {
            auto x = T(0x11);
            auto c = U(-1);
            assert((x & c) == 0x11);
        }
    }
}

unittest 
{
    writeln("xor bool test");
    foreach(T; allTypes)
    {
        auto x = T(0x0101);
        assert((x ^ true) == 0x0100);
        assert((x ^ false) == 0x0101);
    }
}


unittest 
{
    writeln("xor char test");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(char, wchar, dchar))
        {
            auto x = T(0b0101);
            auto c = U(0b1111);
            auto d = U(0b0000);
            assert((x ^ c) == 0b1010);
            assert((x ^ d) == 0b0101);
        }

    }
}

unittest 
{
    writeln("xor integral test");
    foreach(T; allTypes)
    {
        foreach(U; _all)
        {
            auto x = T(0b0101);
            auto c = U(0b1111);
            auto d = U(0b0000);
            assert((x ^ c) == 0b1010);
            assert((x ^ d) == 0b0101);
        }

        foreach(U; _signed)
        {
            auto x = T(0b0101);
            auto c = U(-1);
            assert((x ^ c) == (-1 ^ 0b0101));
        }
    }
}

unittest 
{
    writeln("xor fixed test");
    foreach(T; allTypes)
    {
        foreach(U; allTypes)
        {
            auto x = T(0b0101);
            auto c = U(0b1111);
            auto d = U(0b0000);
            assert((x ^ c) == 0b1010);
            assert((x ^ d) == 0b0101);
        }

        foreach(U; signedTypes)
        {
            auto x = T(0b0101);
            auto c = U(-1);
            assert((x ^ c) == (-1 ^ 0b0101));
        }
    }
}

unittest 
{
    writeln("<< test");
    foreach(T; allTypes)
    {
        auto x           =T(0x0000000001234567UL);
        assert((x << 4)  == 0x0000000012345670UL);
        assert((x << 32) == 0x0123456700000000UL);
        assert((x << 36) == 0x1234567000000000UL);
    }
}

unittest 
{
    writeln(">>> test");
    foreach(T; allTypes)
    {
        auto x            =T(0x1234567000000000UL);
        assert((x >>> 4)  == 0x0123456700000000UL);
        assert((x >>> 32) == 0x0000000012345670UL);
        assert((x >>> 36) == 0x0000000001234567UL);
    }
}

unittest 
{
    writeln(">> test");
    foreach(T; allTypes)
    {
        auto x           =T(0x1234567000000000UL);
        assert((x >> 4)  == 0x0123456700000000UL);
        assert((x >> 32) == 0x0000000012345670UL);
        assert((x >> 36) == 0x0000000001234567UL);
    }

    foreach(T; signedTypes)
    {
        auto x           =T(-1);
        assert((x >> 4)  == -1);
        assert((x >> 32) == -1);
        assert((x >> 36) == -1);
    }
}

unittest 
{
    writeln("string constructor");
    foreach(T; allTypes)
    {
        assert(T("0x0") == 0);
        assert(T("0x1234") == 0x1234);
        assert(T("0x12_34") == 0x1234);
        assert(T("123") == 123);
        assert(T("+123") == 123);
        assert(T("0b0") == 0);
        assert(T("0b1111") == 0b1111);
        assert(T("0b1_1_1_0") == 0b1110);
        assert(T("0o1411") == 777);
    }
}


unittest 
{
    
    writeln("range constructor");
    foreach(T; allTypes)
    {
        assert(T(take("0x0", 3)) == 0);
		//assert(T("0x1234") == 0x1234);
		//assert(T("0x12_34") == 0x1234);
		//assert(T("123") == 123);
		//assert(T("+123") == 123);
		//assert(T("0b0") == 0);
		//assert(T("0b1111") == 0b1111);
		//assert(T("0b1_1_1_0") == 0b1110);
		//assert(T("0o1411") == 777);
    }
}

unittest 
{
    writeln("float constructor");
    foreach(T; allTypes)
    {
        foreach(U; TypeTuple!(float, double, real))
        {
            assert(T(U(0.0) == 0));
            assert(T(U(1.0) == 1));
            assert(T(U(1E3) == 1000));
        }
        
    }
}

unittest 
{
    writeln("operations test");
    foreach(m; ss_data)
    {
        switch (m.size)
        {
            case 96:
                assert(FixedInt!96(m.left) + FixedInt!96(m.right) == FixedInt!96(m.addresult));
                assert(FixedInt!96(m.left) - FixedInt!96(m.right) == FixedInt!96(m.subresult));
                assert(FixedInt!96(m.left) * FixedInt!96(m.right) == FixedInt!96(m.mulresult));
                assert(FixedInt!96(m.left) / FixedInt!96(m.right) == FixedInt!96(m.divresult));
                assert(FixedInt!96(m.left) % FixedInt!96(m.right) == FixedInt!96(m.remresult));
                break;
            case 128:
                assert(FixedInt!128(m.left) + FixedInt!128(m.right) == FixedInt!128(m.addresult));
                assert(FixedInt!128(m.left) - FixedInt!128(m.right) == FixedInt!128(m.subresult));
                assert(FixedInt!128(m.left) * FixedInt!128(m.right) == FixedInt!128(m.mulresult));
                assert(FixedInt!128(m.left) / FixedInt!128(m.right) == FixedInt!128(m.divresult));
                assert(FixedInt!128(m.left) % FixedInt!128(m.right) == FixedInt!128(m.remresult));
                break;
            case 160:
                assert(FixedInt!160(m.left) + FixedInt!160(m.right) == FixedInt!160(m.addresult));
                assert(FixedInt!160(m.left) - FixedInt!160(m.right) == FixedInt!160(m.subresult));
                assert(FixedInt!160(m.left) * FixedInt!160(m.right) == FixedInt!160(m.mulresult));
                assert(FixedInt!160(m.left) / FixedInt!160(m.right) == FixedInt!160(m.divresult));
                assert(FixedInt!160(m.left) % FixedInt!160(m.right) == FixedInt!160(m.remresult));
                break;
            case 192:
                assert(FixedInt!192(m.left) + FixedInt!192(m.right) == FixedInt!192(m.addresult));
                assert(FixedInt!192(m.left) - FixedInt!192(m.right) == FixedInt!192(m.subresult));
                assert(FixedInt!192(m.left) * FixedInt!192(m.right) == FixedInt!192(m.mulresult));
                assert(FixedInt!192(m.left) / FixedInt!192(m.right) == FixedInt!192(m.divresult));
                assert(FixedInt!192(m.left) % FixedInt!192(m.right) == FixedInt!192(m.remresult));
                break;

            default:
                writefln("Warning: %d bits is not tested", m.size);
                break;
        }
    }
}

unittest 
{
    writeln("format test");
    string[] formats = [
        "%d", "%+d", "%-d", "% d", "%+-d", 
        "%5d", "%+5d", "%-5d", "% 5d", "%+-5d",
        "%05d", "%+05d", "%-05d", "% 05d", "%+-05d",
        "%x", "%+x", "%-x", "% x", "%+-x",
        "%5x", "%+5x", "%-5x", "% 5x", "%+-5x",
        "%05x", "%+05x", "%-05x", "% 05x", "%+-05x",
        "%X", "%+X", "%-X", "% X", "%+-X",
        "%5X", "%+5X", "%-5X", "% 5X", "%+-5X",
        "%05X", "%+05X", "%-05X", "% 05X", "%+-05X",
        "%o", "%+o", "%-o", "% o", "%+-o",
        "%5o", "%+5o", "%-5o", "% 5o", "%+-5o",
        "%05o", "%+05o", "%-05o", "% 05o", "%+-05o",
        "%b", "%+b", "%-b", "% b", "%+-b",
        "%32b", "%+32b", "%-32b", "% 32b", "%+-32b",
        "%032b", "%+032b", "%-032b", "% 032b", "%+-032b",
        "%5s", "%+5s", "%-5s", "% 5s", "%+-5s",
        "%05s", "%+05s", "%-05s", "% 05s", "%+-05s",
    ];
    foreach(T; allTypes)
    {
        foreach(f; formats)
        {
            auto expected = format(f, 123);
            auto result = format(f, T(123));
            assert(expected == result, format("'%s' - Expected: '%s', Result: '%s'", f, expected, result)); 
        }
    }

    
}