enum Participant { user, model }

class ChatMessage {
  final String message;
  final bool done;
  final Participant sender;

  ChatMessage(
      {required this.message, required this.done, required this.sender});

  Map<String, dynamic> toMap() {
    return {
      "message": message,
      "done": done,
      "sender": sender == Participant.user ? "user" : "model",
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map["message"] ?? "",
      done: map["done"] ?? false,
      sender: map["sender"] == "user" ? Participant.user : Participant.model,
    );
  }
}
