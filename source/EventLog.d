module EventLog;

import test;
import std.stdio;

class EventLog {
	void Log(T)(T event) {
		writeln(event);
	}
}

class Test: TestSuite {
	struct TestObject {
		string stringMember;
		int intMember;
	}

	this() {
		AddTest(&Log);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Log() {
		auto eventLog = new EventLog();
		eventLog.Log(TestObject("text", 11));
	}
}

unittest {
	auto test = new Test;
	test.Run();
}