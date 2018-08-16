module entities.User;

import test;
import std.algorithm;
import std.uni;
import std.uuid;
import std.stdio;

struct NewUser {
	string name;
	string password;
}

struct User {
	UUID uuid;
	string name;
}

class UserStore {
	User[] users;

	bool Add(NewUser newUser) {
		if(UsernameIsTaken(newUser.name)) {
			return false;
		}

		users ~= User(
			randomUUID,
			newUser.name
		);
		return true;
	}

	bool UsernameIsTaken(string name) {
		return users.any!((a) => toLower(a.name) == toLower(name));
	}

	User[] FindByName(string name) {
		return users.find!((a, b) => toLower(a.name) == b)(toLower(name));
	}
}

class Test: TestSuite {
	this() {
		AddTest(&AddUser_stores_new_users_with_unique_ids);
		AddTest(&Looking_up_missing_username_gives_empty_list);
		AddTest(&Adding_existing_username_does_not_duplicate_it);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void AddUser_stores_new_users_with_unique_ids() {
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

	void Looking_up_missing_username_gives_empty_list() {
		auto userStore = new UserStore;
		assertEqual(0, userStore.FindByName("Test").length);
	}

	void Adding_existing_username_does_not_duplicate_it() {
		auto userStore = new UserStore;
		NewUser newUser = {
			name: "Test"
		};
		assertEqual(true, userStore.Add(newUser));
		assertEqual(false, userStore.Add(newUser));
		assertEqual(1, userStore.FindByName("Test").length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}