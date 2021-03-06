module interactors.Login;

import std.uuid;
import std.json;
import dauth;
import painlessjson;

import test;
import DependencyStore;
import entities.User;
import entities.Key;
import entities.Session;

struct Credentials {
	string session;
	string name;
	string password;
}

class Login {
	UserStore userStore;
	KeyStore keyStore;
	SessionStore sessionStore;

	this(DependencyStore dependencyStore) {
		userStore = dependencyStore.Use!UserStore;
		keyStore = dependencyStore.Use!KeyStore;
		sessionStore = dependencyStore.Use!SessionStore;
	}

	bool opCall(Credentials credentials) {
		User[] users = userStore.FindByName(credentials.name);

		if(users.length == 0) {
			return false;
		}

		auto key = keyStore.FindByLock(users[0].uuid)[0];
		if(!isSameHash(toPassword(credentials.password.dup), parseHash(key.value))) {
			return false;
		}

		auto sessions = sessionStore.FindByUUID(credentials.session);
		if(sessions.length == 0) {
			return false;
		}

		sessions[0].values["user"] = users[0].uuid;
		return true;
	}
}

class Test: TestSuite {
	Login login;
	SessionStore sessionStore;
	SessionCreated sessionCreated;
	UserCreated userCreated;

	this() {
		AddTest(&Login_creates_session_associated_with_user);
		AddTest(&Incorrect_password_fails);
	}

	override void Setup() {
		auto dependencyStore = new DependencyStore;
		sessionStore = new SessionStore;
		dependencyStore.Add(sessionStore);
		auto userStore = new UserStore;
		dependencyStore.Add(userStore);
		auto keyStore = new KeyStore;
		dependencyStore.Add(keyStore);

		login = new Login(dependencyStore);

		sessionCreated = SessionCreated(randomUUID.toString);
		sessionStore.Created(sessionCreated);

		userCreated = UserCreated(randomUUID.toString, "Test");
		userStore.Created(userCreated);

		string hashedPassword = makeHash(toPassword("test".dup)).toString();
		KeyCreated keyCreated = {
			uuid: randomUUID.toString,
			lock: userCreated.uuid, 
			value: hashedPassword
		};
		keyStore.Created(keyCreated);
	}

	void Login_creates_session_associated_with_user() {
		Credentials credentials = {
			session: sessionCreated.uuid,
			name: "Test",
			password: "test"
		};
		assert(login(credentials));

		auto sessions = sessionStore.FindByUUID(sessionCreated.uuid);
		assertEqual(sessions[0].values["user"], userCreated.uuid);
	}

	void Incorrect_password_fails() {
		Credentials credentials = {
			name: "Test",
			password: "wrong"
		};
		assert(!login(credentials));
	}

	void Incorrect_username_fails() {
		Credentials credentials = {
			name: "Nouser",
			password: "test"
		};
		assert(!login(credentials));
	}
}

unittest {
	auto test = new Test;
	test.Run();
}