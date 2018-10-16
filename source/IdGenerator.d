module IdGenerator;

import std.uuid;

class IdGenerator {
	string opCall() {
		return randomUUID.toString;
	}
}