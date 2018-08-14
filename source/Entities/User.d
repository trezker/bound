module entities.User;

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
