struct NewUser {
	string name;
}

class UserCreator {
	void Add(NewUser newUser) {
		
	}
}

unittest {
	auto userCreator = new UserCreator;
}

unittest {
}

unittest {
	NewUser newUser = {
		name: "Test"
	};
	auto userCreator = new UserCreator;
	userCreator.Add(newUser);
}