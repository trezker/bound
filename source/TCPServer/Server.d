import std.json;
import std.socket;
import std.bitmanip;
import std.algorithm;
import std.array;
import std.stdio;
import core.thread;
import test;

alias MessageHandler = JSONValue delegate(JSONValue message);
class Server {
	MessageHandler[string] handlers;
	bool listening = false;
	bool stopped = false;

	void SetHandler(string name, MessageHandler handler) {
		handlers[name] = handler;
	}

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
								client.send(response.toString());
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
					newSocket.send("Listening");
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

		//TODO: Set up a client, send message and verify response.
		auto socket = new Socket(AddressFamily.INET,  SocketType.STREAM);
		socket.connect(new InternetAddress("localhost", 2525));

		char[512] buffer;
		socket.receive(buffer);

		string message = "{\"handler\": \"test\", \"sent\": \"text\"}";
		ubyte[8] binarylength = nativeToBigEndian(message.length);
		socket.send(binarylength);
		socket.send(message);
		writeln("Sent message");

		auto readSet = new SocketSet();
		while(true) {
			Thread.yield();
//			Thread.sleep( dur!("msecs")( 1000 ) ); 
			readSet.reset();
			readSet.add(socket);
			if(Socket.select(readSet, null, null)) {
				writeln("Client reading");
				auto received = socket.receive(buffer);
				writeln(buffer[0 .. received]);
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