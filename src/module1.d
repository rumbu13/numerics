module module1;

struct MyRange
{
	@property bool empty() { return true; }
	void popFront();
	@property char front() { return 'a'; }
}

struct MyRange2
{
	int dummy;
}

@property bool empty(MyRange2 r) { return true; }
void popFront(ref MyRange2 r);
@property char front(MyRange2 r) { return 'a'; }