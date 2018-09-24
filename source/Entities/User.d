module entities.User;

import test;
import std.algorithm;
import std.uni;
import std.uuid;
import std.stdio;

struct UserCreated {
	string uuid;
	string name;
}

struct User {
	string uuid;
	string name;
}

class UserStore {
	User[] users;

	void Created(UserCreated userCreated) {
		users ~= User(
			userCreated.uuid,
			userCreated.name
		);
	}

	User[] FindByName(string name) {
		return users.find!((a, b) => toLower(a.name) == b)(toLower(name));
	}
}

class Test: TestSuite {
	this() {
		AddTest(&Can_store_a_new_user);
		AddTest(&Looking_up_missing_username_gives_empty_list);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Can_store_a_new_user() {
		auto userStore = new UserStore;
		UserCreated newUser = {
			uuid: randomUUID.toString,
			name: "Test"
		};
		userStore.Created(newUser);

		auto user1 = userStore.FindByName("Test")[0];
		assertEqual("Test", user1.name);
	}

	void Looking_up_missing_username_gives_empty_list() {
		auto userStore = new UserStore;
		assertEqual(0, userStore.FindByName("Test").length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}