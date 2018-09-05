module interactors.Login;

import test;
import dauth;
import std.uuid;
import entities.User;
import entities.Key;
import entities.Session;

struct Credentials {
	string name;
	string password;
}

class Login {
	UserStore userStore;
	KeyStore keyStore;
	SessionStore sessionStore;

	UUID opCall(Credentials credentials) {
		User[] users = userStore.FindByName(credentials.name);

		auto sessionCreated = SessionCreated(randomUUID, users[0].uuid);
		sessionStore.Created(sessionCreated);
		return sessionCreated.uuid;
	}
}

class Test: TestSuite {
	this() {
		AddTest(&Login_creates_session_associated_with_user);
	}

	void Login_creates_session_associated_with_user() {
		auto sessionStore = new SessionStore;
		auto userStore = new UserStore;

		auto login = new Login;
		login.userStore = userStore;
		login.keyStore = new KeyStore;
		login.sessionStore = sessionStore;

		auto userCreated = UserCreated(randomUUID, "Test");
		userStore.Created(userCreated);

		Credentials credentials = {
			name: "Test",
			password: "test"
		};
		UUID sessionUUID = login(credentials);

		assertNotEqual(sessionUUID, UUID.init);

		auto currentUser = sessionStore.FindByUUID(sessionUUID);
		assertEqual(currentUser[0].useruuid, userCreated.uuid);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}