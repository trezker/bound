module entities.User;

import test;

struct NewUser {
	string name;
}

struct User {
	string name;
}

class UserStore {
	void Add(NewUser newUser) {

	}

	User FindByName(string name) {
		return User("Test");
	}
}

class Test: TestSuite {
	this() {
		AddTest(&UserEntity);
		AddTest(&AddUser);
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
		assertEqual("Test", userStore.FindByName("Test").name);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}