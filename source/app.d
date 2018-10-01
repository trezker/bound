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

import entities.Session;

class Handler {
	CreateSession interactor;

	JSONValue call(JSONValue message) {
		return interactor().toJSON;
	}
}

void main() {
	auto server = new Server();
	server.internetAddress = new InternetAddress("localhost", 2525);

	auto sessionStore = new SessionStore;
	string IdGenerator() {
		return randomUUID.toString;
	}


	auto createSession = new CreateSession;
	createSession.sessionStore = sessionStore;
	createSession.idGenerator = &IdGenerator;

	auto handler = new Handler;
	handler.interactor = createSession;

	server.SetHandler("test", &handler.call);

	server.Run();
}
