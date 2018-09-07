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

		if(users.length == 0) {
			return UUID.init;
		}

		auto key = keyStore.FindByLockUUID(users[0].uuid)[0];
		if(!isSameHash(toPassword(credentials.password.dup), parseHash(key.value))) {
			return UUID.init;
		}

		auto sessionCreated = SessionCreated(randomUUID, users[0].uuid);
		sessionStore.Created(sessionCreated);
		return sessionCreated.uuid;
	}
}

class Test: TestSuite {
	Login login;
	SessionStore sessionStore;
	UserCreated userCreated;

	this() {
		AddTest(&Login_creates_session_associated_with_user);
		AddTest(&Incorrect_password_fails);
	}

	override void Setup() {
		sessionStore = new SessionStore;
		auto userStore = new UserStore;
		auto keyStore = new KeyStore;

		login = new Login;
		login.userStore = userStore;
		login.keyStore = keyStore;
		login.sessionStore = sessionStore;

		userCreated = UserCreated(randomUUID, "Test");
		userStore.Created(userCreated);

		string hashedPassword = makeHash(toPassword("test".dup)).toString();
		NewKey newKey = {
			lockUUID: userCreated.uuid, 
			value: hashedPassword
		};
		keyStore.Add(newKey);
	}

	void Login_creates_session_associated_with_user() {
		Credentials credentials = {
			name: "Test",
			password: "test"
		};
		UUID sessionUUID = login(credentials);

		assertNotEqual(sessionUUID, UUID.init);

		auto currentUser = sessionStore.FindByUUID(sessionUUID);
		assertEqual(currentUser[0].useruuid, userCreated.uuid);
	}

	void Incorrect_password_fails() {
		Credentials credentials = {
			name: "Test",
			password: "wrong"
		};
		UUID sessionUUID = login(credentials);
		assertEqual(sessionUUID, UUID.init);
	}

	void Incorrect_username_fails() {
		Credentials credentials = {
			name: "Nouser",
			password: "test"
		};
		UUID sessionUUID = login(credentials);
		assertEqual(sessionUUID, UUID.init);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}