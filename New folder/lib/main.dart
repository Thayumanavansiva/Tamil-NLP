import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_mind_map.dart';

void main() {
  runApp(const MindMapApp());
}

class MindMapApp extends StatelessWidget {
  const MindMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'மன வரைபடம் உருவாக்கி',
      theme: ThemeData.dark(),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatMessage {
  final String role;
  final dynamic content;
  ChatMessage({required this.role, required this.content});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [
    ChatMessage(role: "assistant", content: "உங்கள் பத்தியை உள்ளிடுங்கள், மன வரைபடம் உருவாகும்!")
  ];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty || isLoading) return;

    setState(() {
      messages.add(ChatMessage(role: "user", content: _controller.text));
      isLoading = true;
    });

    final input = _controller.text.trim();
    _controller.clear();

    setState(() {
      messages.add(ChatMessage(role: "assistant", content: "மனது வரைபடம் உருவாக்கப்படுகிறது..."));
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/extract_keywords"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"text": input}),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final data = json.decode(decoded) as Map<String, dynamic>;
        final centerLabel = data['name'] as String;
        final children = (data['children'] as List<dynamic>)
            .map((e) => e['name'] as String)
            .toList();
            
        setState(() {
          messages.removeLast();
          messages.add(ChatMessage(
            role: "assistant",
            content: CustomMindMap(centerLabel: centerLabel, children: children),
          ));
        });
      } else {
        throw Exception("API returned error");
      }
    } catch (e) {
      final mockData = {
        "name": "மனப்பகர்வு வழிகாட்டிகள்",
        "children": [
          {"name": "தெளிவானது"},
          {"name": "மையம்"},
          {"name": "பாணி"},
          {"name": "பயன்பாடு"},
          {"name": "முக்கிய சொற்கள்"},
          {"name": "வரிகள்"},
        ],
      };

      final centerLabel = mockData['name'] as String;
      final children = (mockData['children'] as List<dynamic>)
          .map((e) => e['name'] as String)
          .toList();

      setState(() {
        messages.removeLast();
        messages.add(ChatMessage(
          role: "assistant",
          content: CustomMindMap(centerLabel: centerLabel, children: children),
        ));
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset('assets/logo.png', width: 300, fit: BoxFit.contain),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "மன வரைபடம் உருவாக்கி",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Colors.grey),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.role == "user";

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.white : Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: msg.content is String
                            ? Text(
                                msg.content,
                                style: TextStyle(
                                  color: isUser ? Colors.black : Colors.white,
                                  fontSize: 15,
                                ),
                              )
                            : msg.content,
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          hintText: "உங்கள் உரையை இங்கே பதிவு செய்யவும்...",
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white10,
                        ),
                        onSubmitted: (_) => sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading ? null : sendMessage,
                      child: Text(isLoading ? "தயாரிக்கிறது..." : "அனுப்பு"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}