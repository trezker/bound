module entities.Session;

import std.uuid;
import std.algorithm;


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

	Session[] FindByUUID(UUID uuid) {
		return sessions.find!((a) => a.uuid == uuid)();
	}	
}