module interactors.CreateSession;

import test;
import std.uuid;
import entities.Session;

class CreateSession {
	SessionStore sessionStore;

	string opCall() {
		auto sessionCreated = SessionCreated(randomUUID.toString);
		sessionStore.Created(sessionCreated);
		return sessionCreated.uuid;
	}
}

class Test: TestSuite {
	CreateSession createSession;
	SessionStore sessionStore;

	this() {
		AddTest(&CreateSession_creates_session_and_returns_uuid);
	}

	override void Setup() {
		sessionStore = new SessionStore;

		createSession = new CreateSession;
		createSession.sessionStore = sessionStore;
	}

	void CreateSession_creates_session_and_returns_uuid() {
		string sessionUUID = createSession();

		assertNotEqual(sessionUUID, UUID.init.toString);

		auto currentUser = sessionStore.FindByUUID(sessionUUID);
		assertEqual(1, currentUser.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}