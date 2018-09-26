module EventLog;

import test;
import std.stdio;
import std.uuid;
import std.datetime;
import std.variant;
import std.conv;
import std.json;
import std.algorithm;
import painlessjson;

alias LogWriter = bool delegate(string);
alias LogLineCallback = void delegate(string);
alias LogReader = void delegate(LogLineCallback);

struct EventType {
	string name;
	TypeInfo typeInfo;
	void delegate(JSONValue) loader;
}

class EventLog {
	EventType[TypeInfo] eventTypes;
	//string path;
	LogWriter logWriter;
	LogReader logReader;

	void AddType(EventType type) {
		eventTypes[type.typeInfo] = type;
	}

	bool Log(T)(T event) {
		JSONValue json;
		json["timestamp"] = JSONValue(Clock.currTime.toISOExtString);
		json["data"] = event.toJSON;
		json["type"] = eventTypes[typeid(event)].name;
		
		return logWriter(json.toString());
		/*
		File file = File(path, "a");
		file.writeln(json.toString());
		file.close();*/
	}

	void Load() {
		EventType[string] eventTypesByName;
		foreach(type; eventTypes.byValue()) {
			eventTypesByName[type.name] = type;
		}

		void LoadLine(string line) {
			JSONValue json = parseJSON(line);
			eventTypesByName[json["type"].str].loader(json);
		}

		logReader(&LoadLine);
/*
		File file = File(path, "r"); 
		while(!file.eof) {
			string line = file.readln();
			if(line != "") {
				JSONValue json = parseJSON(line);
				eventTypesByName[json["type"].str].loader(json);
			}
		}

		file.close();*/
	}
}

class MemoryLog {
	string[] logs;

	bool Write(string log) {
		logs ~= log;
		return true;
	}

	void Read(LogLineCallback callback) {
		logs.each!(line => callback(line));

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
	}

	void Loader(JSONValue json) {
		eventsLoaded ~= json["data"].fromJSON!(EventTested);
	}

	void Log() {
		MemoryLog log = new MemoryLog;
		auto eventLog = new EventLog();
		eventLog.logWriter = &log.Write;
		eventLog.logReader = &log.Read;

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

struct TestStuff {
	string stuffString;
	int stuffInt;
}

struct EventTested {
	string stringMember;
	int intMember;
	TestStuff[] stuffs;
}

unittest {
	auto test = new Test;
	test.Run();
}