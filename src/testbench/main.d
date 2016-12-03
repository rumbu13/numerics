//import std.typetuple;
//import std.datetime;
//import std.typecons;

//import std.format;
//import std.typetuple;
//import std.random;
import std.range;
import std.traits: isSomeChar;
//import std.random;
//import std.datetime;
////
//import mixins;
//import test_shift;


void test(R)(R range) if (isInputRange!R)
{
	//
}

int main(string[] argv)
{
	static assert(isInputRange!(typeof(take("some string", 3))));

	test(take("some string", 3));

	return 0;
    
}
