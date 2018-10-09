module interactors.CurrentUser;

import std.stdio;
import std.uuid;
import EventLog;
import DependencyStore;
import test;
import entities.User;
import entities.Session;

class CurrentUser {
	private UserStore userStore;
	private SessionStore sessionStore;

	this(DependencyStore dependencyStore) {
		sessionStore = dependencyStore.Use!SessionStore;
		userStore = dependencyStore.Use!UserStore;
	}

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
		auto dependencyStore = new DependencyStore;
		userStore = new UserStore;
		dependencyStore.Add(userStore);

		auto sessionStore = new SessionStore;
		dependencyStore.Add(sessionStore);

		auto userCreated = UserCreated(randomUUID.toString(), "test");
		userStore.Created(userCreated);

		auto sessionCreated = SessionCreated(randomUUID.toString);
		sessionStore.Created(sessionCreated);
		auto sessions = sessionStore.FindByUUID(sessionCreated.uuid);
		sessions[0].values["user"] = userCreated.uuid;

		currentUser = new CurrentUser(dependencyStore);

		auto user = currentUser(sessionCreated.uuid);

		assertEqual(userCreated.name, user.name);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}