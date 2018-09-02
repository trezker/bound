module entities.User;

import test;
import std.algorithm;
import std.uni;
import std.uuid;
import std.stdio;

struct UserCreated {
	UUID uuid;
	string name;
}

struct User {
	UUID uuid;
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
		AddTest(&Created_stores_new_users);
		AddTest(&Looking_up_missing_username_gives_empty_list);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void Created_stores_new_users() {
		auto userStore = new UserStore;
		UserCreated newUser = {
			uuid: randomUUID,
			name: "Test"
		};
		userStore.Created(newUser);
		UserCreated newUser2 = {
			uuid: randomUUID,
			name: "Test2"
		};
		userStore.Created(newUser2);

		auto user1 = userStore.FindByName("Test")[0];
		auto user2 = userStore.FindByName("Test2")[0];
		assertEqual("Test", user1.name);
		assertEqual("Test2", user2.name);

		assertNotEqual(user1.uuid, user2.uuid);
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