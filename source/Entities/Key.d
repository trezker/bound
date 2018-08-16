module entities.Key;

import std.uuid;
import std.algorithm;

struct NewKey {
	UUID lockUUID;
	string value;
}

struct Key {
	UUID uuid;
	UUID lockUUID;
	string value;
}

class KeyStore {
	Key[] keys;

	void Add(NewKey newKey) {
		keys ~= Key(
			randomUUID,
			newKey.lockUUID,
			newKey.value
		);
	}

	Key[] FindByLockUUID(UUID lockUUID) {
		return keys.find!((a, b) => a.lockUUID == b)(lockUUID);
	}
}