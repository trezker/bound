module interactors.UserCreator;

import test;
import dauth;
import entities.User;
import entities.Key;

class UserCreator {
	UserStore userStore;
	KeyStore keyStore;

	bool Add(NewUser newUser) {
		if(!userStore.Add(newUser)) {
			return false;
		}

		User user = userStore.FindByName(newUser.name)[0];
		string hashedPassword = makeHash(toPassword(newUser.password.dup)).toString();
		NewKey newKey = {
			lockUUID: user.uuid, 
			value: hashedPassword
		};
		keyStore.Add(newKey);
		return true;
	}
}

class Test: TestSuite {
	this() {
		AddTest(&AddUser_stores_user_with_encrypted_password);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void AddUser_stores_user_with_encrypted_password() {
		NewUser newUser = {
			name: "Test",
			password: "foo"
		};
		auto userStore = new UserStore;
		auto keyStore = new KeyStore;
		auto userCreator = new UserCreator;
		userCreator.userStore = userStore;
		userCreator.keyStore = keyStore;
		userCreator.Add(newUser);

		auto users = userStore.FindByName("Test");
		assertEqual(1, users.length);

		auto key = keyStore.FindByLockUUID(users[0].uuid)[0];
		assert(isSameHash(toPassword(newUser.password.dup), parseHash(key.value)));
	}
}

unittest {
	auto test = new Test;
	test.Run();
}