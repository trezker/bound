import std.stdio;


void main() {
/*
	auto listener = new Socket(AddressFamily.INET, SocketType.STREAM, ProtocolType.TCP);
	listener.bind(new InternetAddress("localhost", 2525));
	listener.listen(10);

	auto readSet = new SocketSet();
	Socket[] connectedClients;
	bool isRunning = true;
	
	while(isRunning) {
		readSet.reset();
		readSet.add(listener);
		
		foreach(client; connectedClients)
			readSet.add(client);
		
		if(Socket.select(readSet, null, null)) {
			foreach(client; connectedClients) {
				if(readSet.isSet(client)) {
					string message = ReadMessage(client);
					if(message.length == 0) {
						connectedClients = filter!(a => a != client)(connectedClients).array;
					}
					writeln("Client sent: ", message);
				}
			}

			if(readSet.isSet(listener)) {
				// the listener is ready to read, that means
				// a new client wants to connect. We accept it here.
				auto newSocket = listener.accept();
				newSocket.send("Hello!\n"); // say hello
				connectedClients ~= newSocket; // add to our list
			}
		}
	}*/
}
