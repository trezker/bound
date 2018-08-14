module interactors.UserCreator;

import test;
import entities.User;

class UserCreator {
	void Add(NewUser newUser) {

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
		auto userCreator = new UserCreator;
		userCreator.Add(newUser);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}