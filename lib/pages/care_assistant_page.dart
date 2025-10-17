import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';

// import hasil dari `flutterfire configure`
import '../firebase_options.dart';

import 'home_page.dart';
import 'custom_bottom_nav_bar.dart';

// --- Model data pesan ---
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class CareAssistantPage extends StatefulWidget {
  const CareAssistantPage({super.key});

  @override
  State<CareAssistantPage> createState() => _CareAssistantPageState();
}

class _CareAssistantPageState extends State<CareAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  late final GenerativeModel _model;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndModel();
    _messages.add(
      ChatMessage(
        text:
            'Halo 👋, saya CareBot, asisten AI pribadi kamu. Ada yang bisa saya bantu hari ini?',
        isUser: false,
      ),
    );
  }

  // --- Inisialisasi Firebase dan Model ---
  Future<void> _initFirebaseAndModel() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final firebaseAuth = FirebaseAuth.instance;
      final firebaseAiInstance = FirebaseAI.vertexAI(auth: firebaseAuth);

      _model = firebaseAiInstance.generativeModel(
        model: 'gemini-2.5-flash-lite',
        generationConfig: GenerationConfig(
          temperature: 1.0,
          maxOutputTokens: 2000,
          topP: 0.95,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none, null),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.none,
            null,
          ),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.none,
            null,
          ),
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none, null),
        ],
      );

      setState(() => _initialized = true);
    } catch (e, st) {
      debugPrint('Init Firebase/Model failed: $e\n$st');
      setState(() => _initialized = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Fungsi ekstraktor teks yang aman ---
  String _extractTextFromResponse(dynamic resp) {
    try {
      final r = resp as dynamic;

      // 1) langsung text / generatedText
      try {
        final t = r.text;
        if (t != null && (t as String).trim().isNotEmpty) return t as String;
      } catch (_) {}
      try {
        final t = r.generatedText;
        if (t != null && (t as String).trim().isNotEmpty) return t as String;
      } catch (_) {}

      // 2) candidates
      try {
        final candidates = r.candidates;
        if (candidates != null && (candidates as List).isNotEmpty) {
          final first = candidates[0];
          try {
            final out = first.outputText;
            if (out != null && (out as String).trim().isNotEmpty) {
              return out as String;
            }
          } catch (_) {}
          try {
            final out2 = first.text ?? first.content;
            if (out2 != null && (out2 as String).trim().isNotEmpty) {
              return out2 as String;
            }
          } catch (_) {}
        }
      } catch (_) {}

      // 3) output -> content.parts[*].text
      try {
        final output = r.output;
        if (output != null && (output as List).isNotEmpty) {
          final content = output[0].content;
          if (content != null) {
            final parts = content.parts as List?;
            if (parts != null && parts.isNotEmpty) {
              final texts = parts
                  .map((p) {
                    try {
                      return (p.text ?? p['text'] ?? '').toString();
                    } catch (_) {
                      return p.toString();
                    }
                  })
                  .where((s) => s.trim().isNotEmpty)
                  .toList();
              if (texts.isNotEmpty) return texts.join('\n');
            }
          }
        }
      } catch (_) {}

      // 4) coba toJson
      try {
        final Map<String, dynamic> map = (r.toJson() as Map<String, dynamic>);
        String longest = '';
        void traverse(dynamic node) {
          if (node == null) return;
          if (node is String) {
            if (node.trim().length > longest.length) longest = node.trim();
          } else if (node is Map) {
            node.values.forEach(traverse);
          } else if (node is List) {
            node.forEach(traverse);
          }
        }

        traverse(map);
        if (longest.isNotEmpty) return longest;
      } catch (_) {}

      // 5) fallback ke toString
      try {
        final s = resp.toString();
        if (s.trim().isNotEmpty) return s;
      } catch (_) {}
    } catch (_) {}

    return '';
  }

  // --- Kirim pesan ke AI ---
  Future<void> _sendMessage() async {
    if (!_initialized) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Model belum siap. Tunggu sebentar ya.',
            isUser: false,
          ),
        );
      });
      return;
    }

    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final chatHistory = _messages
          .where((m) => !m.text.contains('Halo 👋'))
          .map(
            (m) => Content(m.isUser ? 'user' : 'assistant', [TextPart(m.text)]),
          )
          .toList();

      final response = await _model.generateContent(chatHistory);

      // Debug: lihat struktur respons
      try {
        debugPrint('AI response (toString): ${response.toString()}');
      } catch (_) {}

      final botRaw = _extractTextFromResponse(response);
      final botMessage = botRaw.trim().isNotEmpty
          ? botRaw.trim()
          : 'Maaf, saya tidak bisa merespons saat ini.';

      setState(() {
        _messages.add(ChatMessage(text: botMessage, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e, st) {
      debugPrint('Error sending message: $e\n$st');
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Oops, terjadi kesalahan saat menghubungi AI. Coba lagi nanti ya!',
            isUser: false,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Care Assistant',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg-chat.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoading && index == _messages.length) {
                      return _buildLoadingIndicator();
                    }
                    final msg = _messages[index];
                    return msg.isUser
                        ? _buildUserMessage(msg.text)
                        : _buildBotMessage(msg.text);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: SvgPicture.asset(
              'assets/svgs/care_assistant.svg',
              height: 24,
              width: 24,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: text,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. GANTI _buildLoadingIndicator DENGAN ANIMASI MENGETIK
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: SvgPicture.asset(
              'assets/svgs/care_assistant.svg',
              height: 24,
              width: 24,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TypingIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Kamu Boleh Curhat Disini...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFFE91E63)),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

// 3. TAMBAHKAN WIDGET BARU UNTUK ANIMASI MENGETIK
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Logika untuk menampilkan 1, 2, atau 3 titik
        final dotCount = (1 + (_controller.value * 3).floor()).clamp(1, 3);
        return Text(
          '.' * dotCount,
          style: const TextStyle(
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        );
      },
    );
  }
}
