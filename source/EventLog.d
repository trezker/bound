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
	string path;

	void AddType(EventType type) {
		eventTypes[type.typeInfo] = type;
	}

	void Log(T)(T event) {
		JSONValue json;
		json["timestamp"] = JSONValue(Clock.currTime.toISOExtString);
		json["data"] = event.toJSON;
		json["type"] = eventTypes[typeid(event)].name;
		
		File file = File(path, "a"); 
		file.writeln(json.toString());
		file.close(); 
	}

	void Load() {
		EventType[string] eventTypesByName;
		foreach(type; eventTypes.byValue()) {
			eventTypesByName[type.name] = type;
		}

		File file = File(path, "r"); 
		while(!file.eof) {
			string line = file.readln();
			if(line != "") {
				JSONValue json = parseJSON(line);
				eventTypesByName[json["type"].str].loader(json);
			}
		}

		file.close();
	}
}

class Test: TestSuite {
	EventTested[] eventsLoaded;

	this() {
		AddTest(&Log);
	}

	override void Setup() {
	}

	override void Teardown() {
		remove("test.log");
	}

	void Loader(JSONValue json) {
		//writeln(json);
		eventsLoaded ~= json["data"].fromJSON!(EventTested);
	}

	void Log() {
		auto eventLog = new EventLog();
		eventLog.path = "test.log";

		auto type = EventType("EventTested", typeid(EventTested), &this.Loader);
		eventLog.AddType(type);

		TestStuff[] stuffs;
		stuffs ~= TestStuff("str", 14);
		auto event1 = EventTested("one", 11, stuffs);
		auto event2 = EventTested("two", 22, stuffs);

		eventLog.Log(event1);
		eventLog.Log(event2);
		
		eventLog.Load();
		assertEqual(event1, eventsLoaded[0]);
		assertEqual(event2, eventsLoaded[1]);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}