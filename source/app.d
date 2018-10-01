import std.stdio;
import std.json;
import std.uuid;
import painlessjson;
import std.socket;

import Network.Server;
import interactors.CreateSession;
import interactors.CreateUser;
import interactors.CurrentUser;
import interactors.Login;
import interactors.Logout;

import EventLog;
import entities.Session;
import entities.User;
import entities.Key;

class Handler(T) {
	T interactor;

	JSONValue call(JSONValue message) {
		return interactor().toJSON;
	}
}

class Handler(T, U) {
	T interactor;

	JSONValue call(JSONValue message) {
		U data = message["data"].fromJSON!(U);
		return interactor(data).toJSON;
	}
}

void main() {
	string IdGenerator() {
		return randomUUID.toString;
	}
	auto sessionStore = new SessionStore;
	auto userStore = new UserStore;
	auto keyStore = new KeyStore;

	auto log = new MemoryLog;
	auto eventLog = new EventLog();
	eventLog.logWriter = &log.Write;
	eventLog.logReader = &log.Read;
	auto userCreatedType = EventType("UserCreated", typeid(UserCreated), null);
	eventLog.AddType(userCreatedType);
	auto keyCreatedType = EventType("KeyCreated", typeid(KeyCreated), null);
	eventLog.AddType(keyCreatedType);


	auto createSession = new CreateSession;
	createSession.sessionStore = sessionStore;
	createSession.idGenerator = &IdGenerator;
	auto createSessionHandler = new Handler!(CreateSession);
	createSessionHandler.interactor = createSession;

	auto createUser = new CreateUser;
	createUser.userStore = userStore;
	createUser.keyStore = keyStore;
	createUser.eventLog = eventLog;
	createUser.idGenerator = &IdGenerator;
	auto createUserHandler = new Handler!(CreateUser, NewUser);
	createUserHandler.interactor = createUser;

	auto server = new Server();
	server.internetAddress = new InternetAddress("localhost", 2525);

	server.SetHandler("CreateSession", &createSessionHandler.call);
	server.SetHandler("CreateUser", &createUserHandler.call);

	//server.Run();
}
