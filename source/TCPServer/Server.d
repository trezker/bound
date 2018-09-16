import std.json;
import std.socket;
import std.bitmanip;
import std.algorithm;
import std.array;
import std.stdio;
import core.thread;
import test;

string ReadMessage(Socket socket) {
	ubyte[8] binarylength;
	auto l = socket.receive(binarylength);
	auto length = bigEndianToNative!long(binarylength);

	string message;

	long total = 0;
	char[] buffer;
	buffer.length = length;
	while(total < length) {
		auto got = socket.receive(buffer);
		total += got;
		message ~= buffer[0 .. got];
	}
	return message;
}

void SendMessage(Socket socket, string message) {
	ubyte[8] binarylength = nativeToBigEndian(message.length);
	socket.send(binarylength);
	socket.send(message);
}

alias MessageHandler = JSONValue delegate(JSONValue message);
class Server {
	MessageHandler[string] handlers;
	bool listening = false;
	bool stopped = false;

	void SetHandler(string name, MessageHandler handler) {
		handlers[name] = handler;
	}

	void Stop() {
		stopped = true;
		listening  = false;
	}

	void Run() {
		writeln("Run server");
		auto listener = new Socket(
			AddressFamily.INET, 
			SocketType.STREAM, 
			ProtocolType.TCP
		);
		listener.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
		listener.bind(new InternetAddress("localhost", 2525));
		listener.listen(10);
		listening = true;
		writeln("Server listening");

		auto readSet = new SocketSet();
		Socket[] connectedClients;

		while(!stopped) {
			Thread.yield();
			readSet.reset();
			readSet.add(listener);
			foreach(client; connectedClients)
				readSet.add(client);
			
			if(Socket.select(readSet, null, null)) {
				foreach(client; connectedClients) {
					if(readSet.isSet(client)) {
						string message = ReadMessage(client);
						writeln("Received: ", message);
						if(message.length == 0) {
							writeln("Client disconnected");
							connectedClients = 
								filter!(a => a != client)
								(connectedClients).array;
						}
						else {
							try {
								JSONValue json = parseJSON(message);
								writeln("Received: ", json);
								JSONValue response = handlers[json["handler"].str](json);
								SendMessage(client, response.toString());
							}
							catch(Exception e) {
								writeln(e);
							}
						}
					}
				}

				if(readSet.isSet(listener)) {
					auto newSocket = listener.accept();
					connectedClients ~= newSocket;
					writeln("Client connected");
				}
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
		server.SetHandler("test", &this.MessageHandler);

		auto serverThread = new Thread(&server.Run).start();
		writeln("Started serverThread");
		while(!server.listening) {
			writeln("Waiting");
			Thread.yield();
			Thread.sleep( dur!("msecs")( 1000 ) ); 
		}
		writeln("Confirmed server is listening");

		auto socket = new Socket(AddressFamily.INET,  SocketType.STREAM);
		socket.connect(new InternetAddress("localhost", 2525));

		string message = "{\"handler\": \"test\", \"sent\": \"text\"}";
		SendMessage(socket, message);
		writeln("Sent message");

		auto readSet = new SocketSet();
		while(true) {
			//TODO: Do we actually need any yielding
			Thread.yield();
			readSet.reset();
			readSet.add(socket);
			if(Socket.select(readSet, null, null)) {
				writeln("Client reading");
				//TODO: Then I should also implement a generic client class that handles sending and receiving.
				string received = ReadMessage(socket);
				writeln(received);
				break;
			}
		}

		server.Stop();
	}
}

unittest {
	auto test = new Test;
	test.Run();
}