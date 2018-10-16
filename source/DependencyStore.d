module DependencyStore;

import std.variant;
import test;

struct Dependency {

}

class DependencyStore {
	Variant[TypeInfo] dependencies;

	void Add(T)(T instance) {
		dependencies[typeid(T)] = instance;
	}

	T Use(T)() {
		return dependencies[typeid(T)].get!T;
	}
}

class Test: TestSuite {
	this() {
		AddTest(&Stored_instances_are_available_on_demand);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Stored_instances_are_available_on_demand() {
		auto dependencyStore = new DependencyStore;
		auto testIn = new TestDependency;
		dependencyStore.Add(testIn);
		auto testOut = dependencyStore.Use!TestDependency;
		assertEqual(testIn, testOut);
	}
}

class TestDependency {
}

unittest {
	auto test = new Test;
	test.Run();
}