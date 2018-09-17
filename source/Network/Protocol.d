module Network.Protocol;

import std.socket;
import std.bitmanip;

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
