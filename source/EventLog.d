module EventLog;

import test;
import std.stdio;
import std.uuid;
import std.datetime;
import std.variant;
import std.conv;
import std.json;
import painlessjson;

struct TestStuff {
	string stuffString;
	int stuffInt;
}

struct EventTested {
	string stringMember;
	int intMember;
	TestStuff[] stuffs;
}

struct EventType {
	string name;
	TypeInfo typeInfo;
}

class EventLog {
	EventType[TypeInfo] eventTypes;

	void AddType(EventType type) {
		eventTypes[type.typeInfo] = type;
	}

	void Log(T)(T event) {
		JSONValue json;
		json["timestamp"] = JSONValue(Clock.currTime.toISOExtString);
		json["data"] = event.toJSON;
		json["type"] = eventTypes[typeid(event)].name;
		writeln(json);
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
		TestStuff[] stuffs;
		stuffs ~= TestStuff("str", 14);
		auto eventLog = new EventLog();
		auto type = EventType("EventTested", typeid(EventTested));
		eventLog.AddType(type);
		auto eventTested = EventTested("text", 11, stuffs);

		eventLog.Log(eventTested);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}