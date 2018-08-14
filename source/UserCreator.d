struct NewUser {
	string name;
}

class UserCreator {

}

unittest {
	auto userCreator = new UserCreator;
}

unittest {
	NewUser newUser = {
		name: "Test"
	};
}