module interactors.CreateSession;

import test;
import std.uuid;
import DependencyStore;
import entities.Session;

class CreateSession {
	private SessionStore sessionStore;
	string delegate() idGenerator;

	this(DependencyStore dependencyStore) {
		sessionStore = dependencyStore.Use!SessionStore;
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

		createSession = new CreateSession(dependencyStore);
		string IdGenerator() {
			return randomUUID.toString;
		}
		createSession.idGenerator = &IdGenerator;
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