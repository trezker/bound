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
	
	void UserEntity() {
		User user = {
			name: "Test"
		};
	}

	void AddUserStore() {
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