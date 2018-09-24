module entities.Session;

import std.uuid;
import std.algorithm;
import std.array;
import test;

struct SessionCreated {
	UUID uuid;
	UUID useruuid;
}

struct Session {
	UUID uuid;
	UUID useruuid;
}

class SessionStore {
	Session[] sessions;

	void Created(SessionCreated sessionCreated) {
		sessions ~= Session(
			sessionCreated.uuid, 
			sessionCreated.useruuid
		);
	}

	void Deleted(UUID uuid) {
		sessions = filter!(a => a.uuid != uuid)(sessions).array;
	}

	Session[] FindByUUID(UUID uuid) {
		return sessions.find!((a) => a.uuid == uuid)();
	}	
}

class Test: TestSuite {
	this() {
		AddTest(&Created_stores_a_new_session);
		AddTest(&Deleted_removes_session);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Created_stores_a_new_session() {
		auto sessionStore = new SessionStore;
		SessionCreated newSession = {
			uuid: randomUUID,
			useruuid: randomUUID,
		};
		sessionStore.Created(newSession);

		auto sessions = sessionStore.FindByUUID(newSession.uuid);
		assertEqual(1, sessions.length);
	}

	void Deleted_removes_session() {
		auto sessionStore = new SessionStore;
		SessionCreated newSession = {
			uuid: randomUUID,
			useruuid: randomUUID,
		};
		sessionStore.Created(newSession);

		sessionStore.Deleted(newSession.uuid);

		auto sessions = sessionStore.FindByUUID(newSession.uuid);
		assertEqual(0, sessions.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}