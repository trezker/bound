module entities.User;

import test;
import std.algorithm;
import std.uni;
import std.uuid;
import std.stdio;

struct NewUser {
	string name;
}

struct User {
	UUID uuid;
	string name;
}

class UserStore {
	User[] users;

	void Add(NewUser newUser) {
		if(UsernameIsFree(newUser.name)) {
			users ~= User(
				randomUUID,
				newUser.name
			);
		}
	}

	bool UsernameIsFree(string name) {
		User[] r = users.find!((a, b) => toLower(a.name) == b)(toLower(name));
		return r.length == 0;
	}

	User[] FindByName(string name) {
		return users.find!((a, b) => toLower(a.name) == b)(toLower(name));
	}
}

class Test: TestSuite {
	this() {
		AddTest(&UserEntity);
		AddTest(&AddUser);
		AddTest(&FindByName_not_existing);
		AddTest(&AddUserDuplicateNameError);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void UserEntity() {
		User user = {
			name: "Test"
		};
	}

	void AddUser() {
		auto userStore = new UserStore;
		NewUser newUser = {
			name: "Test"
		};
		userStore.Add(newUser);
		NewUser newUser2 = {
			name: "Test2"
		};
		userStore.Add(newUser2);

		auto user1 = userStore.FindByName("Test")[0];
		auto user2 = userStore.FindByName("Test2")[0];
		assertEqual("Test", user1.name);
		assertEqual("Test2", user2.name);

		assertNotEqual(user1.uuid, user2.uuid);
	}

	void FindByName_not_existing() {
		auto userStore = new UserStore;
		assertEqual(0, userStore.FindByName("Test").length);
	}

	void AddUserDuplicateNameError() {
		auto userStore = new UserStore;
		NewUser newUser = {
			name: "Test"
		};
		userStore.Add(newUser);
		userStore.Add(newUser);
		assertEqual(1, userStore.FindByName("Test").length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}