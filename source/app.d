import std.stdio;
import std.json;
import std.uuid;
import painlessjson;
import std.socket;
import poodinis;

import Network.Server;
import interactors.CreateSession;
import interactors.CreateUser;
import interactors.CurrentUser;
import interactors.Login;
import interactors.Logout;

import EventLog;
import IdGenerator;
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
	auto dependencies = new shared DependencyContainer();
	auto idGenerator = dependencies.resolve!IdGenerator(ResolveOption.registerBeforeResolving);
	auto sessionStore = dependencies.resolve!SessionStore(ResolveOption.registerBeforeResolving);
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


	auto createSession = dependencies.resolve!CreateSession(ResolveOption.registerBeforeResolving);
	auto createSessionHandler = new Handler!(CreateSession);
	createSessionHandler.interactor = createSession;

	auto createUser = new CreateUser;
	createUser.userStore = userStore;
	createUser.keyStore = keyStore;
	createUser.eventLog = eventLog;
	createUser.idGenerator = idGenerator;
	auto createUserHandler = new Handler!(CreateUser, NewUser);
	createUserHandler.interactor = createUser;

	auto currentUser = new CurrentUser;
	currentUser.userStore = userStore;
	currentUser.sessionStore = sessionStore;
	auto currentUserHandler = new Handler!(CurrentUser, string);
	currentUserHandler.interactor = currentUser;

	auto login = new Login;
	login.userStore = userStore;
	login.keyStore = keyStore;
	login.sessionStore = sessionStore;
	auto loginHandler = new Handler!(Login, Credentials);
	loginHandler.interactor = login;

	auto logout = new Logout;
	logout.sessionStore = sessionStore;
	auto logoutHandler = new Handler!(Logout, string);
	logoutHandler.interactor = logout;


	auto server = new Server();
	server.internetAddress = new InternetAddress("localhost", 2525);

	server.SetHandler("CreateSession", &createSessionHandler.call);
	server.SetHandler("CreateUser", &createUserHandler.call);
	server.SetHandler("CurrentUser", &currentUserHandler.call);
	server.SetHandler("Login", &loginHandler.call);

	server.Run();
}
