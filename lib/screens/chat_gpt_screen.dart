import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttler_chat_gpt/core/app_theme.dart';
import 'package:fluttler_chat_gpt/models/chat_model.dart';
import 'package:fluttler_chat_gpt/repositories/chat_gpt_repository.dart';

class ChatGptScreen extends StatefulWidget {
  const ChatGptScreen({Key? key}) : super(key: key);

  @override
  State<ChatGptScreen> createState() => _ChatGptScreenState();
}

class _ChatGptScreenState extends State<ChatGptScreen> {
  final _inputCtrl = TextEditingController();
  final _repository = ChatGptRepository(Dio());
  final _messages = <ChatModel>[];
  final _scrollCtrl = ScrollController();

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'ChatGPT - Flutter',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          padding: const EdgeInsets.all(10),
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: _messages.length,
                itemBuilder: (_, int index) {
                  return Row(
                    children: [
                      if (_messages[index].messengeFrom == MessageFrom.me)
                        const Spacer(),
                      // Message
                      Container(
                        margin: const EdgeInsets.all(12),
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _messages[index].message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )),
              TextField(
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                maxLines: 4,
                minLines: 1,
                controller: _inputCtrl,
                decoration: InputDecoration(
                    hintText: 'Digite aqui...',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppTheme.secondaryColor,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.secondaryColor,
                    suffixIcon: IconButton(
                      onPressed: () async {
                        if (_inputCtrl.text.isNotEmpty) {
                          final prompt = _inputCtrl.text;

                          setState(() {
                            _messages.add(ChatModel(
                              message: prompt,
                              messengeFrom: MessageFrom.me,
                            ));

                            _inputCtrl.clear();

                            _scrollDown();
                          });

                          final chatResponse =
                              await _repository.promptMessage(prompt);

                          setState(() {
                            _messages.add(ChatModel(
                              message: chatResponse,
                              messengeFrom: MessageFrom.bot,
                            ));

                            _scrollDown();
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
