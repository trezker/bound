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

import DependencyStore;
import IdGenerator;
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
	auto dependencyStore = new DependencyStore;
	dependencyStore.Add(new IdGenerator);
	auto sessionStore = new SessionStore;
	dependencyStore.Add(sessionStore);
	auto userStore = new UserStore;
	dependencyStore.Add(userStore);
	auto keyStore = new KeyStore;
	dependencyStore.Add(keyStore);

	auto eventLog = new EventLog();
	dependencyStore.Add(eventLog);
	auto log = new MemoryLog;
	eventLog.logWriter = &log.Write;
	eventLog.logReader = &log.Read;
	auto userCreatedType = EventType("UserCreated", typeid(UserCreated), null);
	eventLog.AddType(userCreatedType);
	auto keyCreatedType = EventType("KeyCreated", typeid(KeyCreated), null);
	eventLog.AddType(keyCreatedType);


	auto createSession = new CreateSession(dependencyStore);
	auto createSessionHandler = new Handler!(CreateSession);
	createSessionHandler.interactor = createSession;

	auto createUser = new CreateUser(dependencyStore);
	auto createUserHandler = new Handler!(CreateUser, NewUser);
	createUserHandler.interactor = createUser;

	auto currentUser = new CurrentUser(dependencyStore);
	auto currentUserHandler = new Handler!(CurrentUser, string);
	currentUserHandler.interactor = currentUser;

	auto login = new Login(dependencyStore);
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
