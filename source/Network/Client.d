module Network.Client;

import std.socket;
import std.json;
import core.thread;
import test;
import Network.Server;
import Network.Protocol;

class Client {
	Socket socket;

	void Connect() {
		auto socket = new Socket(
			AddressFamily.INET, 
			SocketType.STREAM, 
			ProtocolType.TCP
		);
		socket.connect(new InternetAddress("localhost", 2525));
	}

	O Message(I, O)(string handler, I input) {
		JSONValue json;
		json["handler"] = JSONValue(handler);
		json["data"] = event.toJSON;

		SendMessage(socket, json.toString());
		string received = ReadMessage(socket);
		JSONValue json = parseJSON(line);
		return json.fromJSON!(O);
	}
}


class Test: TestSuite {
	this() {
		AddTest(&Server_calls_handler_for_a_message);
	}

	JSONValue MessageHandler(JSONValue message) {
		JSONValue response;
		response["got"] = message["sent"];
		return response;
	}

	void Server_calls_handler_for_a_message() {
		auto server = new Server;
		server.SetHandler("test", &this.MessageHandler);

		auto serverThread = new Thread(&server.Run).start();
		while(!server.listening) {}

		auto socket = new Socket(
			AddressFamily.INET, 
			SocketType.STREAM, 
			ProtocolType.TCP
		);
		socket.connect(new InternetAddress("localhost", 2525));

		string message = "{\"handler\": \"test\", \"sent\": \"text\"}";
		SendMessage(socket, message);

		string received;
		auto readSet = new SocketSet();
		while(true) {
			readSet.reset();
			readSet.add(socket);
			if(Socket.select(readSet, null, null)) {
				//TODO: I should also implement a generic client class that handles sending and receiving.
				received = ReadMessage(socket);
				break;
			}
		}

		JSONValue json = parseJSON(received);
		assertEqual("text", json["got"].str);

		server.Stop();
		serverThread.join();
	}
}

unittest {
	auto test = new Test;
	test.Run();
}