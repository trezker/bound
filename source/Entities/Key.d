module entities.Key;

import std.uuid;
import std.algorithm;
import test;

struct KeyCreated {
	string uuid;
	string lock;
	string value;
}

struct Key {
	string uuid;
	string lock;
	string value;
}

class KeyStore {
	Key[] keys;

	void Created(KeyCreated keyCreated) {
		keys ~= Key(
			keyCreated.uuid,
			keyCreated.lock,
			keyCreated.value
		);
	}

	Key[] FindByLock(string lock) {
		return keys.find!((a, b) => a.lock == b)(lock);
	}
}


class Test: TestSuite {
	this() {
		AddTest(&Created_stores_a_new_key);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Created_stores_a_new_key() {
		auto keyStore = new KeyStore;
		KeyCreated keyCreated = {
			uuid: randomUUID.toString,
			lock: randomUUID.toString,
			value: "value"
		};
		keyStore.Created(keyCreated);

		auto keys = keyStore.FindByLock(keyCreated.lock);
		assertEqual(1, keys.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}