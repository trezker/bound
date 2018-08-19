module interactors.Login;

import test;
import dauth;
import std.uuid;
import entities.User;
import entities.Key;

class Login {
	UserStore userStore;
	KeyStore keyStore;

	UUID opCall(Credentials credentials) {

	}
}

class Test: TestSuite {
	this() {
		AddTest(&ads);
	}

	void ads() {
		auto login = new Login;
		login.userStore = new UserStore;
		login.keyStore = new KeyStore;

		Credentials credentials = {
			name: "Test",
			password: "test"
		};
		UUID sessionUUID = login(credentials);

		assertNotEqual(sessionUUID, UUID.init);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}