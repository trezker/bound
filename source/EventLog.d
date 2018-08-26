module EventLog;

import test;
import std.stdio;
import std.uuid;
import std.datetime;
import std.variant;
import std.conv;

struct EventTested {
	string stringMember;
	int intMember;
}

class Event {
	private SysTime time;
	private Variant data;

	this(T)(T data) {
		time = Clock.currTime();
		this.data = data;
	}

	Variant Data() {
		return data;
	}

	SysTime Time() {
		return time;
	}
}

class EventLog {
	void Log(Event event) {
		EventTested data = *event.Data.peek!(EventTested);
		writeln(data);
	}
}

class Test: TestSuite {
	this() {
		AddTest(&Log);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Log() {
		auto eventLog = new EventLog();
		auto eventTested = EventTested("text", 11);

		eventLog.Log(new Event(eventTested));
	}
}

unittest {
	auto test = new Test;
	test.Run();
}