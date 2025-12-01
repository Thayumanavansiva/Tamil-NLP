import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'custom_mind_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

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
      content: "உரை உள்ளிடவும் அல்லது படத்தை தேர்வு செய்து உரையை பெறவும்!",
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  // 🔥 PICK IMAGE FROM GALLERY → EXTRACT TEXT WITH OCR
  Future<void> pickImageAndExtract() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;
      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            role: "assistant",
            content: "🔍 உரை பிரித்தெடுக்கப்படுகிறது...",
          ),
        );
      });

      try {
        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );

        await textRecognizer.close();

        final extracted = recognizedText.text.trim();

        if (!mounted) return;
        setState(() {
          messages.removeLast();
        });

        if (extracted.isEmpty) {
          setState(() {
            messages.add(
              ChatMessage(
                role: "assistant",
                content: "❌ படத்தில் உரை கண்டறிய முடியவில்லை",
              ),
            );
          });
          return;
        }

        setState(() {
          _controller.text = extracted;
          messages.add(
            ChatMessage(
              role: "assistant",
              content: "✅ உரை பிரித்தெடுக்கப்பட்டது. இப்போது அனுப்புவும்!",
            ),
          );
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          messages.removeLast();
          messages.add(
            ChatMessage(role: "assistant", content: "❌ OCR பிழை: $e"),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ பிழை: $e")));
    }
  }

  // 🔥 PICK FILE (IMAGE OR DOC) → EXTRACT TEXT WITH OCR
  Future<void> pickFileAndExtract() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final filePath = file.path;

      if (filePath == null) return;
      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            role: "assistant",
            content: "🔍 உரை பிரித்தெடுக்கப்படுகிறது...",
          ),
        );
      });

      try {
        if (file.extension?.toLowerCase() == 'pdf') {
          setState(() {
            messages.removeLast();
            messages.add(
              ChatMessage(
                role: "assistant",
                content:
                    "⚠️ PDF ஆதரவு சீக்கிரம் கிடைக்கும். பதிலாக படத்தை பயன்படுத்தவும்.",
              ),
            );
          });
          return;
        }

        final inputImage = InputImage.fromFilePath(filePath);
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );

        await textRecognizer.close();

        final extracted = recognizedText.text.trim();

        if (!mounted) return;

        setState(() {
          messages.removeLast();
        });

        if (extracted.isEmpty) {
          setState(() {
            messages.add(
              ChatMessage(
                role: "assistant",
                content: "❌ கோப்பில் உரை கண்டறிய முடியவில்லை",
              ),
            );
          });
          return;
        }

        setState(() {
          _controller.text = extracted;
          messages.add(
            ChatMessage(
              role: "assistant",
              content: "✅ உரை பிரித்தெடுக்கப்பட்டது. இப்போது அனுப்புவும்!",
            ),
          );
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          messages.removeLast();
          messages.add(
            ChatMessage(role: "assistant", content: "❌ OCR பிழை: $e"),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ பிழை: $e")));
    }
  }

  // 🔥 SEND TEXT → BACKEND → GET MIND MAP
  Future<void> sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || isLoading) return;

    setState(() {
      messages.add(ChatMessage(role: "user", content: input));
      isLoading = true;
      messages.add(
        ChatMessage(
          role: "assistant",
          content: "🔄 மன வரைபடம் உருவாக்கப்படுகிறது...",
        ),
      );
    });

    _controller.clear();

    try {
      final res = await http.post(
        Uri.parse("http://127.0.0.1:5000/extract_keywords"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": input}),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(res.bodyBytes),
        );

        final String center = jsonData["title"] ?? "மையம் இல்லை";
        final List<String> children =
            (jsonData["keywords"] as List?)
                ?.map((e) => e["keywords"] as String)
                .toList() ??
            [];

        if (!mounted) return;
        setState(() {
          messages.removeLast();
          messages.add(
            ChatMessage(
              role: "assistant",
              content: CustomMindMap(centerLabel: center, children: children),
            ),
          );
        });
      } else {
        throw Exception("Server error ${res.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.removeLast();
        messages.add(ChatMessage(role: "assistant", content: "❌ பிழை: $e"));
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // UI SECTION
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

          // Messages
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
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.white : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: msg.content is String
                        ? Text(
                            msg.content,
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.white,
                            ),
                          )
                        : msg.content,
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white24),

          // Input area
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 🔥 FILE & IMAGE BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : pickFileAndExtract,
                        icon: const Icon(Icons.upload_file),
                        label: const Text("📄 பதிவேற்று"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : pickImageAndExtract,
                        icon: const Icon(Icons.image),
                        label: const Text("📷 படம்"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // TEXT INPUT
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !isLoading,
                        decoration: const InputDecoration(
                          hintText: "உரை எழுதவும் அல்லது அப்லோட் செய்யவும்...",
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
