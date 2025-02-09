enum Sender { user, model }

class Message {
  final String text;
  final Sender sender;

  Message({required this.text, required this.sender});
}

enum ChatMode { synchronous, streaming }
