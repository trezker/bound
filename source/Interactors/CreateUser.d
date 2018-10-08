module interactors.CreateUser;

import std.uuid;
import std.stdio;
import std.json;
import painlessjson;
import dauth;

import test;
import EventLog;
import DependencyStore;
import entities.User;
import entities.Key;

struct NewUser {
	string name;
	string password;
}

class CreateUser {
	private UserStore userStore;
	private KeyStore keyStore;
	private EventLog eventLog;
	string delegate() idGenerator;

	this(DependencyStore dependencyStore) {
		userStore = dependencyStore.Use!UserStore;
		keyStore = dependencyStore.Use!KeyStore;
		eventLog = dependencyStore.Use!EventLog;
	}

	bool opCall(NewUser newUser) {
		User[] user = userStore.FindByName(newUser.name);
		if(user.length > 0) {
			return false;
		}

		auto userCreated = UserCreated(idGenerator(), newUser.name);
		eventLog.Log(userCreated);
		userStore.Created(userCreated);

		string hashedPassword = makeHash(toPassword(newUser.password.dup)).toString();
		KeyCreated keyCreated = {
			uuid: idGenerator(),
			lock: userCreated.uuid, 
			value: hashedPassword
		};
		eventLog.Log(keyCreated);
		keyStore.Created(keyCreated);
		return true;
	}
}

class Test: TestSuite {
	UserStore userStore;
	KeyStore keyStore;
	CreateUser userCreator;
	EventLog eventLog;

	this() {
		AddTest(&CreateUser_stores_user_with_encrypted_password);
		AddTest(&CreateUser_does_not_allow_duplicate_usernames);
		AddTest(&Adding_user_writes_to_eventlog);
	}

	override void Setup() {
		auto dependencyStore = new DependencyStore;
		userStore = new UserStore;
		dependencyStore.Add(userStore);
		keyStore = new KeyStore;
		dependencyStore.Add(keyStore);
		eventLog = new EventLog();
		dependencyStore.Add(eventLog);
		auto log = new MemoryLog;
		eventLog.logWriter = &log.Write;
		eventLog.logReader = &log.Read;
		auto userCreatedType = EventType("UserCreated", typeid(UserCreated), &this.UserLoader);
		eventLog.AddType(userCreatedType);
		auto keyCreatedType = EventType("KeyCreated", typeid(KeyCreated), &this.KeyLoader);
		eventLog.AddType(keyCreatedType);

		userCreator = new CreateUser(dependencyStore);
		string IdGenerator() {
			return randomUUID.toString;
		}
		userCreator.idGenerator = &IdGenerator;
	}

	override void Teardown() {
		remove("test.log");
	}

	UserCreated[] usersLoadedFromEventLog;
	KeyCreated[] keysLoadedFromEventLog;
	void UserLoader(JSONValue json) {
		usersLoadedFromEventLog ~= json["data"].fromJSON!(UserCreated);
	}
	void KeyLoader(JSONValue json) {
		keysLoadedFromEventLog ~= json["data"].fromJSON!(KeyCreated);
	}

	void CreateUser_stores_user_with_encrypted_password() {
		NewUser newUser = {
			name: "Test",
			password: "foo"
		};
		userCreator(newUser);		

		auto users = userStore.FindByName("Test");
		assertEqual(1, users.length);

		auto key = keyStore.FindByLock(users[0].uuid)[0];
		assert(isSameHash(toPassword(newUser.password.dup), parseHash(key.value)));
	}

	void CreateUser_does_not_allow_duplicate_usernames() {
		NewUser newUser = {
			name: "Test",
			password: "foo"
		};

		userCreator(newUser);
		userCreator(newUser);

		auto users = userStore.FindByName("Test");
		assertEqual(1, users.length);
	}

	void Adding_user_writes_to_eventlog() {
		NewUser newUser = {
			name: "Test",
			password: "foo"
		};
		userCreator(newUser);

		eventLog.Load();
		assertEqual(1, usersLoadedFromEventLog.length);
	}
}

unittest {
	auto test = new Test;
	test.Run();
}