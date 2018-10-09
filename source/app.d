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
	private T interactor;

	this(T i) {
		interactor = i;
	}

	JSONValue call(JSONValue message) {
		return interactor().toJSON;
	}
}

class Handler(T, U) {
	private T interactor;

	this(T i) {
		interactor = i;
	}

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
	auto createSessionHandler = new Handler!(CreateSession)(createSession);

	auto createUser = new CreateUser(dependencyStore);
	auto createUserHandler = new Handler!(CreateUser, NewUser)(createUser);

	auto currentUser = new CurrentUser(dependencyStore);
	auto currentUserHandler = new Handler!(CurrentUser, string)(currentUser);

	auto login = new Login(dependencyStore);
	auto loginHandler = new Handler!(Login, Credentials)(login);

	auto logout = new Logout(dependencyStore);
	auto logoutHandler = new Handler!(Logout, string)(logout);


	auto server = new Server();
	server.internetAddress = new InternetAddress("localhost", 2525);

	server.SetHandler("CreateSession", &createSessionHandler.call);
	server.SetHandler("CreateUser", &createUserHandler.call);
	server.SetHandler("CurrentUser", &currentUserHandler.call);
	server.SetHandler("Login", &loginHandler.call);

	server.Run();
}
