import 'package:flutter/material.dart';
// HTTP/backend imports removed while using demo data to avoid unused-import warnings
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'custom_mind_map.dart';

void main() {
  runApp(const MindMapApp());
}

// Backwards-compatible wrapper used by the default widget test which expects
// a `MyApp` class. Keep this thin so tests referencing `MyApp` continue to work.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MindMapApp();
}

class MindMapApp extends StatelessWidget {
  const MindMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'மன வரைபடம் உருவாக்கி',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
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
    ChatMessage(
      role: "assistant",
      content: "உங்கள் பத்தியை உள்ளிடுங்கள், மன வரைபடம் உருவாகும்!",
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  /*
  Future<void> sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || isLoading) return;

    setState(() {
      messages.add(ChatMessage(role: "user", content: input));
      isLoading = true;
    });

    _controller.clear();

    setState(() {
      messages.add(
        ChatMessage(
          role: "assistant",
          content: "மன வரைபடம் உருவாக்கப்படுகிறது...",
        ),
      );
    });

    try {
      final res = await http.post(
        Uri.parse("http://127.0.0.1:8000/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": input}),
      );

      if (res.statusCode == 200) {
        final decoded = utf8.decode(res.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(decoded);

        final String center = jsonData["name"];
        final List<String> childList = (jsonData["children"] as List)
            .map((e) => e["name"] as String)
            .toList();

        setState(() {
          messages.removeLast(); // remove "loading"
          messages.add(
            ChatMessage(
              role: "assistant",
              content: CustomMindMap(centerLabel: center, children: childList),
            ),
          );
        });
      } else {
        throw Exception("Server error ${res.statusCode}");
      }
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add(
          ChatMessage(role: "assistant", content: "❌ பிழை ஏற்பட்டது: $e"),
        );
      });
    }

    setState(() {
      isLoading = false;
    });
  }*/
  Future<void> sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || isLoading) return;

    setState(() {
      messages.add(ChatMessage(role: "user", content: input));
      isLoading = true;
    });

    _controller.clear();

    setState(() {
      messages.add(
        ChatMessage(
          role: "assistant",
          content: "மன வரைபடம் உருவாக்கப்படுகிறது...",
        ),
      );
    });

    await Future.delayed(const Duration(seconds: 1)); // fake loading

    /// DEMO JSON OUTPUT FOR TESTING UI (NO BACKEND)
    final demoJson = {
      "name": "தொழில்நுட்பம்",
      "children": [
        {"name": "மேஷின் லர்னிங்"},
        {"name": "ஏஐ மாடல்கள்"},
        {"name": "டேட்டா சயின்ஸ்"},
        {"name": "மொபைல் அப்ளிக்கேஷன்"},
        {"name": "தகவல் பாதுகாப்பு"},
        {"name": "வேலை வாய்ப்பு"},
      ],
    };

    final String center = demoJson["name"] as String;
    final List<String> childList = (demoJson["children"] as List)
        .map((e) => e["name"] as String)
        .toList();

    setState(() {
      messages.removeLast();
      messages.add(
        ChatMessage(
          role: "assistant",
          content: CustomMindMap(centerLabel: center, children: childList),
        ),
      );
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Text(
            "மன வரைபடம் உருவாக்கி",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.white24),

          /// Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                final isUser = msg.role == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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

          const Divider(color: Colors.white24),

          /// Input Field
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      hintText: "உங்கள் உரையை இங்கே பதிவு செய்யவும்...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : sendMessage,
                  child: Text(isLoading ? "⏳" : "அனுப்பு"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
