module interactors.UserCreator;

import test;
import entities.User;

class UserCreator {
	UserStore userStore;

	void Add(NewUser newUser) {
		userStore.Add(newUser);
	}
}

class Test: TestSuite {
	this() {
		AddTest(&AddUser);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void AddUser() {
		NewUser newUser = {
			name: "Test"
		};
		auto userStore = new UserStore;
		auto userCreator = new UserCreator;
		userCreator.userStore = userStore;
		userCreator.Add(newUser);

		assertEqual(1, userStore.FindByName("Test").length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}