module interactors.CreateSession;

import test;
import std.uuid;
import entities.Session;
import IdGenerator;
import poodinis;

class CreateSession {
	@Autowire
	private SessionStore sessionStore;
	@Autowire
	private IdGenerator idGenerator;

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
		auto dependencies = new shared DependencyContainer();
		sessionStore = dependencies.resolve!SessionStore(ResolveOption.registerBeforeResolving);
		auto idGenerator = dependencies.resolve!IdGenerator(ResolveOption.registerBeforeResolving);

		createSession = dependencies.resolve!CreateSession(ResolveOption.registerBeforeResolving);;
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