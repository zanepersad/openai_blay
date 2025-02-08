import 'package:ablay_ai/const.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAi = OpenAI.instance.build(
    token: apiURL,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(
        seconds: 30,
      ),
    ),
    enableLog: true,
  );
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Kepo', lastName: 'wae');
  final ChatUser _gptChatUSer =
      ChatUser(id: '2', firstName: 'Kang', lastName: 'Ablay');
  List<ChatMessage> _message = <ChatMessage>[];
  List<ChatUser> _typingUsers = <ChatUser>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Ablay AI Brokkk",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      body: DashChat(
          currentUser: _currentUser,
          typingUsers: _typingUsers,
          messageOptions: const MessageOptions(
            currentUserContainerColor: Colors.black,
            containerColor: Colors.grey,
            textColor: Colors.white,
          ),
          onSend: (ChatMessage m) {
            getChatResponse(m);
          },
          messages: _message),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _message.insert(0, m);
      _typingUsers.add(_gptChatUSer);
    });

    List<Map<String, dynamic>> _messageHistory = _message.map((m) {
      return {
        'role': m.user == _currentUser ? 'user' : 'assistant',
        'content': m.text,
      };
    }).toList();

    final request = ChatCompleteText(
      model: Gpt4oMiniChatModel(),
      maxToken: 200,
      messages: _messageHistory,
    );

    try {
      final response = await _openAi.onChatCompletion(request: request);
      print(response); // Debugging: Print the response

      if (response != null && response.choices.isNotEmpty) {
        for (var element in response.choices) {
          if (element.message != null) {
            setState(() {
              _message.insert(
                0,
                ChatMessage(
                  user: _gptChatUSer,
                  createdAt: DateTime.now(),
                  text: element.message!.content,
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      print("Error: $e"); // Debugging: Print any errors
    } finally {
      setState(() {
        _typingUsers.remove(_gptChatUSer);
      });
    }
  }
}
