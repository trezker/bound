module interactors.Logout;

import std.uuid;
import test;
import entities.Session;
import std.stdio;


class Logout {
	SessionStore sessionStore;

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
		auto sessionStore = new SessionStore;
		auto sessionCreated = SessionCreated(randomUUID.toString);
		sessionStore.Created(sessionCreated);

		auto logout = new Logout;
		logout.sessionStore = sessionStore;

		logout(sessionCreated.uuid);

		Session[] sessions = sessionStore.FindByUUID(sessionCreated.uuid);
		assertEqual(0, sessions.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}