struct NewUser {
	string name;
}

struct User {
	string name;
}

class UserStore {
	void Add(NewUser newUser) {

	}
}

class UserCreator {
	void Add(NewUser newUser) {

	}
}

unittest {
	NewUser newUser = {
		name: "Test"
	};
	auto userCreator = new UserCreator;
	userCreator.Add(newUser);
}

unittest {
	User user = {
		name: "Test"
	};
}

unittest {
	auto userStore = new UserStore;
	NewUser newUser = {
		name: "Test"
	};
	userStore.Add(newUser);
}