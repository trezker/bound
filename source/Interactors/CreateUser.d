module interactors.CreateUser;

import test;
import dauth;
import entities.User;
import entities.Key;
import std.uuid;

struct NewUser {
	string name;
	string password;
}

class CreateUser {
	UserStore userStore;
	KeyStore keyStore;

	bool opCall(NewUser newUser) {
		User[] user = userStore.FindByName(newUser.name);
		if(user.length > 0) {
			return false;
		}

		auto userCreated = UserCreated(randomUUID, newUser.name);
		userStore.Created(userCreated);

		string hashedPassword = makeHash(toPassword(newUser.password.dup)).toString();
		NewKey newKey = {
			lockUUID: userCreated.uuid, 
			value: hashedPassword
		};
		keyStore.Add(newKey);
		return true;
	}
}

class Test: TestSuite {
	this() {
		AddTest(&CreateUser_stores_user_with_encrypted_password);
		AddTest(&CreateUser_does_not_allow_duplicate_usernames);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void CreateUser_stores_user_with_encrypted_password() {
		NewUser newUser = {
			name: "Test",
			password: "foo"
		};
		auto userStore = new UserStore;
		auto keyStore = new KeyStore;
		auto userCreator = new CreateUser;
		userCreator.userStore = userStore;
		userCreator.keyStore = keyStore;
		userCreator(newUser);

		auto users = userStore.FindByName("Test");
		assertEqual(1, users.length);

		auto key = keyStore.FindByLockUUID(users[0].uuid)[0];
		assert(isSameHash(toPassword(newUser.password.dup), parseHash(key.value)));
	}

	void CreateUser_does_not_allow_duplicate_usernames() {
		NewUser newUser = {
			name: "Test",
			password: "foo"
		};
		auto userStore = new UserStore;
		auto keyStore = new KeyStore;
		auto userCreator = new CreateUser;
		userCreator.userStore = userStore;
		userCreator.keyStore = keyStore;

		userCreator(newUser);
		userCreator(newUser);

		auto users = userStore.FindByName("Test");
		assertEqual(1, users.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}