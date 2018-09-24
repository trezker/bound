module entities.Key;

import std.uuid;
import std.algorithm;

struct NewKey {
	string lockUUID;
	string value;
}

struct Key {
	string uuid;
	string lockUUID;
	string value;
}

class KeyStore {
	Key[] keys;

	void Add(NewKey newKey) {
		keys ~= Key(
			randomUUID.toString,
			newKey.lockUUID,
			newKey.value
		);
	}

	Key[] FindByLockUUID(string lockUUID) {
		return keys.find!((a, b) => a.lockUUID == b)(lockUUID);
	}
}