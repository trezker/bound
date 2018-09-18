module Network.Server;

import std.json;
import std.socket;
import std.algorithm;
import std.array;
import std.stdio;
import core.thread;
import test;
import Network.Protocol;

alias MessageHandler = JSONValue delegate(JSONValue message);
class Server {
	MessageHandler[string] handlers;
	bool listening = false;
	bool stopped = false;
	Socket[] connectedClients;
	InternetAddress internetAddress;

	void SetHandler(string name, MessageHandler handler) {
		handlers[name] = handler;
	}

	void Stop() {
		stopped = true;
		listening  = false;
	}

	void Run() {
		auto listener = new Socket(
			AddressFamily.INET, 
			SocketType.STREAM, 
			ProtocolType.TCP
		);
		listener.setOption(
			SocketOptionLevel.SOCKET, 
			SocketOption.REUSEADDR, 
			true
		);
		listener.bind(internetAddress);
		listener.listen(10);
		listening = true;

		auto readSet = new SocketSet();

		while(!stopped) {
			readSet.reset();
			readSet.add(listener);
			foreach(client; connectedClients) {
				readSet.add(client);
			}

			if(Socket.select(readSet, null, null, dur!"msecs"(1))) {
				foreach(client; connectedClients) {
					if(readSet.isSet(client)) {
						HandleClient(client);
					}
				}

				if(readSet.isSet(listener)) {
					auto newSocket = listener.accept();
					connectedClients ~= newSocket;
				}
			}
		}
	}

	void HandleClient(Socket client) {
		string message = ReadMessage(client);
		if(message.length == 0) {
			connectedClients = 
				filter!(a => a != client)
				(connectedClients).array;
		}
		else {
			try {
				JSONValue json = parseJSON(message);
				JSONValue response = handlers[json["handler"].str](json);
				SendMessage(client, response.toString());
			}
			catch(Exception e) {
				writeln(e);
			}
		}
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
		server.internetAddress = new InternetAddress("localhost", 2525);
		server.SetHandler("test", &this.MessageHandler);

		auto serverThread = new Thread(&server.Run).start();
		while(!server.listening) {}

		auto socket = new Socket(
			AddressFamily.INET, 
			SocketType.STREAM, 
			ProtocolType.TCP
		);
		socket.connect(server.internetAddress);

		string message = "{\"handler\": \"test\", \"sent\": \"text\"}";
		SendMessage(socket, message);

		string received;
		auto readSet = new SocketSet();
		while(true) {
			readSet.reset();
			readSet.add(socket);
			if(Socket.select(readSet, null, null)) {
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
	//test.Run();
}