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
	void delegate(JSONValue) loader;
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
		
		File file = File("test.log", "a"); 
		file.writeln(json.toString());
		file.close(); 
	}

	void Load() {
		EventType[string] eventTypesByName;
		foreach(type; eventTypes.byValue()) {
			eventTypesByName[type.name] = type;
		}


		writeln("Loading log");
		File file = File("test.log", "r"); 
		string line = file.readln();
		JSONValue json = parseJSON(line);
		writeln(json["type"]);
		eventTypesByName[json["type"].str].loader(json);

		file.close();
	}
}

class Test: TestSuite {
	EventTested event;

	this() {
		AddTest(&Log);
	}

	override void Setup() {
	}

	override void Teardown() {
		remove("test.log");
	}

	void Loader(JSONValue json) {
		writeln(json);
		
	}

	void SetEvent(EventTested e) {
		event = e;
	}

	void Log() {
		auto eventLog = new EventLog();
		auto type = EventType("EventTested", typeid(EventTested), &this.Loader);
		eventLog.AddType(type);

		TestStuff[] stuffs;
		stuffs ~= TestStuff("str", 14);
		auto eventTested = EventTested("text", 11, stuffs);

		eventLog.Log(eventTested);

		eventLog.Load();
	}
}

unittest {
	auto test = new Test;
	test.Run();
}