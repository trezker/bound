struct NewUser {
	string name;
}

struct User {
	string name;
}

class UserStore {
	
}

class UserCreator {
	void Add(NewUser newUser) {

	}
}

unittest {
	auto userCreator = new UserCreator;
}

unittest {
	NewUser newUser = {
		name: "Test"
	};
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
}