module interactors.CurrentUser;

import test;
import entities.User;
import entities.Session;
import std.stdio;
import std.uuid;
import EventLog;

class CurrentUser {
	UserStore userStore;
	SessionStore sessionStore;

	User opCall(string id) {
		auto sessions = sessionStore.FindByUUID(id);
		auto userid = sessions[0].values["user"];

		User[] user = userStore.FindById(userid);
		if(user.length == 0) {
			return User("", "");
		}

		return user[0];
	}
}

class Test: TestSuite {
	UserStore userStore;
	CurrentUser currentUser;

	this() {
		AddTest(&CurrentUser_returns_logged_in_user);
	}

	override void Setup() {
	}

	override void Teardown() {
	}

	void CurrentUser_returns_logged_in_user() {
		userStore = new UserStore;
		auto userCreated = UserCreated(randomUUID.toString(), "test");
		userStore.Created(userCreated);

		auto sessionStore = new SessionStore;
		auto sessionCreated = SessionCreated(randomUUID.toString);
		sessionStore.Created(sessionCreated);
		auto sessions = sessionStore.FindByUUID(sessionCreated.uuid);
		sessions[0].values["user"] = userCreated.uuid;

		currentUser = new CurrentUser;
		currentUser.userStore = userStore;
		currentUser.sessionStore = sessionStore;

		auto user = currentUser(sessionCreated.uuid);

		assertEqual(userCreated.name, user.name);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}