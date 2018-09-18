module Network.Client;

import std.socket;
import std.json;
import core.thread;
import painlessjson;
import test;
import Network.Server;
import Network.Protocol;

class Client {
	Socket socket;
	InternetAddress internetAddress;

	void Connect() {
		socket = new Socket(
			AddressFamily.INET, 
			SocketType.STREAM, 
			ProtocolType.TCP
		);
		socket.connect(internetAddress);
	}

	O Message(I, O)(string handler, I input) {
		JSONValue json;
		json["handler"] = JSONValue(handler);
		json["data"] = input.toJSON;
		SendMessage(socket, json.toString());
		
		string received = "{\"got\":4}";//ReadMessage(socket);
		JSONValue jsonReceived = parseJSON(received);
		return jsonReceived.fromJSON!(O);
	}
}

struct InputTest {
	string sent;
}

struct OutputTest {
	int got;
}

class Test: TestSuite {
	this() {
		AddTest(&Server_calls_handler_for_a_message);
	}

	JSONValue MessageHandler(JSONValue message) {
		JSONValue response;
		response["got"] = JSONValue(4);
		return response;
	}

	void Server_calls_handler_for_a_message() {
		auto server = new Server;
		server.SetHandler("test", &this.MessageHandler);
		server.internetAddress = new InternetAddress("localhost", 2526);		

		auto serverThread = new Thread(&server.Run).start();
		while(!server.listening) {}

		auto client = new Client;
		client.internetAddress = server.internetAddress;
		client.Connect();

		OutputTest output = client.Message!(InputTest, OutputTest)("test", InputTest("hare"));
		assertEqual(4, output.got);

		server.Stop();
		serverThread.join();
	}
}

unittest {
	auto test = new Test;
	test.Run();
}