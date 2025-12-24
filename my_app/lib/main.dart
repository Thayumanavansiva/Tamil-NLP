import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'custom_mind_map.dart';

void main() {
  runApp(const MindMapApp());
}

/// ----------------------------
/// APP ROOT
/// ----------------------------
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

/// ----------------------------
/// CHAT MESSAGE MODEL
/// ----------------------------
class ChatMessage {
  final String role;
  final dynamic content;

  ChatMessage({required this.role, required this.content});
}

/// ----------------------------
/// CHAT SCREEN
/// ----------------------------
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
  final GlobalKey _mindMapKey = GlobalKey();

  bool isLoading = false;

  /// ----------------------------
  /// JSON → TREE PARSER
  /// ----------------------------
  MindMapNode parseMindMap(Map<String, dynamic> json) {
    return MindMapNode(
      label: json["title"] ?? "மைய தலைப்பு இல்லை",
      children: (json["keywords"] as List).map<MindMapNode>((item) {
        return MindMapNode(
          label: item["level1"],
          children: (item["level2"] as List)
              .map<MindMapNode>((sub) => MindMapNode(label: sub))
              .toList(),
        );
      }).toList(),
    );
  }

  /// ----------------------------
  /// DOWNLOAD MIND MAP
  /// ----------------------------
  Future<void> downloadMindMap() async {
    try {
      final ctx = _mindMapKey.currentContext;
      if (ctx == null) {
        throw Exception("Mind map not ready");
      }

      final boundary = ctx.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      // 📱 ANDROID / DESKTOP
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File(
        "${directory.path}/mind_map_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Saved to ${directory.path}")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Download failed: $e")));
    }
  }

  /// ----------------------------
  /// SEND MESSAGE + API CALL
  /// ----------------------------
  Future<void> sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty || isLoading) return;

    setState(() {
      messages.add(ChatMessage(role: "user", content: input));
      isLoading = true;
      messages.add(
        ChatMessage(
          role: "assistant",
          content: "மன வரைபடம் உருவாக்கப்படுகிறது...",
        ),
      );
    });

    _controller.clear();

    try {
      final res = await http.post(
        Uri.parse("http://127.0.0.1:5000/extract_keywords"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"paragraph": input}),
      );

      if (res.statusCode == 200) {
        final decoded = utf8.decode(res.bodyBytes);
        final Map<String, dynamic> jsonData = jsonDecode(decoded);

        final MindMapNode rootNode = parseMindMap(jsonData);

        setState(() {
          messages.removeLast();
          messages.add(
            ChatMessage(
              role: "assistant",
              content: CustomMindMap(
                root: rootNode,
                repaintKey: _mindMapKey,
                onDownload: downloadMindMap, // ✅ PASS CALLBACK
              ),
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// ----------------------------
  /// UI
  /// ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),

          /// TITLE ONLY
          const Text(
            "மன வரைபடம் உருவாக்கி",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const Divider(color: Colors.white24),

          /// CHAT AREA
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
                    margin: const EdgeInsets.symmetric(vertical: 6),
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
                        : msg.content, // 🔥 ONLY THE MAP (BUTTON IS INSIDE)
                  ),
                );
              },
            ),
          ),

          const Divider(color: Colors.white24),

          /// INPUT AREA
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
