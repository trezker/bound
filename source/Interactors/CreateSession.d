module interactors.CreateSession;

import std.uuid;
import test;
import DependencyStore;
import IdGenerator;
import entities.Session;

class CreateSession {
	private SessionStore sessionStore;
	private IdGenerator idGenerator;

	this(DependencyStore dependencyStore) {
		sessionStore = dependencyStore.Use!SessionStore;
		idGenerator = dependencyStore.Use!IdGenerator;
	}

	string opCall() {
		auto sessionCreated = SessionCreated(idGenerator());
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
		auto dependencyStore = new DependencyStore;
		sessionStore = new SessionStore;
		dependencyStore.Add(sessionStore);
		dependencyStore.Add(new IdGenerator);

		createSession = new CreateSession(dependencyStore);
	}

	void CreateSession_creates_session_and_returns_uuid() {
		string sessionUUID = createSession();

		assertNotEqual(sessionUUID, "");

		auto currentUser = sessionStore.FindByUUID(sessionUUID);
		assertEqual(1, currentUser.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}