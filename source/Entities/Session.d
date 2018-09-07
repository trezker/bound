module entities.Session;

import std.uuid;
import std.algorithm;
import std.array;

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