module interactors.Logout;

import std.stdio;
import std.uuid;

import test;
import DependencyStore;
import entities.Session;

class Logout {
	SessionStore sessionStore;

	this(DependencyStore dependencyStore) {
		sessionStore = dependencyStore.Use!SessionStore;
	}

	bool opCall(string uuid) {
		sessionStore.Deleted(uuid);
		return true;
	}
}

class Test: TestSuite {
	this() {
		AddTest(&Logout_removes_session);
	}

	void Logout_removes_session() {
		auto dependencyStore = new DependencyStore;
		auto sessionStore = new SessionStore;
		dependencyStore.Add(sessionStore);

		auto sessionCreated = SessionCreated(randomUUID.toString);
		sessionStore.Created(sessionCreated);

		auto logout = new Logout(dependencyStore);

		logout(sessionCreated.uuid);

		Session[] sessions = sessionStore.FindByUUID(sessionCreated.uuid);
		assertEqual(0, sessions.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}