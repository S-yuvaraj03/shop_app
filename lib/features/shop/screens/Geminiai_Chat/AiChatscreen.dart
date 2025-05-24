import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/messages_list.dart';
import '../../../Providers/providers.dart';

class AichatScreen extends ConsumerStatefulWidget {
  const AichatScreen({super.key});

  @override
  ConsumerState<AichatScreen> createState() => _AichatScreenState();
}

class _AichatScreenState extends ConsumerState<AichatScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  late final TextEditingController _messageController;
  final apiKey = dotenv.env['API_KEY'] ?? '';
  XFile? image;
  bool isLoading = false;
  bool isButtonDisabled = true;
  bool _isInitialMessageSent = false;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;

  final List<String> _suggestions = [
    "Show me the latest products",
    "fastest processor in the world?",
    "how to avail discounts?",
    "Tell me about delivery options"
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    _messageController.addListener(() {
      setState(() {
        isButtonDisabled = _messageController.text.isEmpty && image == null;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage == null) return;
    setState(() {
      image = pickedImage;
      isButtonDisabled = _messageController.text.isEmpty && image == null;
    });
  }

  void _removeImage() {
    setState(() {
      image = null;
      isButtonDisabled = _messageController.text.isEmpty;
    });
  }

  Future<void> sendMessage({String? predefinedMessage}) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty && image == null) return;

    setState(() => isLoading = true);

    if (!_isInitialMessageSent) {
      await ref.read(chatProvider).startChatAndSendMessage(
        apiKey: apiKey,
        initialText: "Hello, Gemini.",
        promptText: message,
      );
      _isInitialMessageSent = true;
    } else {
      await ref.read(chatProvider).sendMessage(
        apiKey: apiKey,
        image: image,
        promptText: message,
      );
    }

    setState(() {
      _messageController.clear();
      image = null;
      isLoading = false;
      isButtonDisabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double kwidth = MediaQuery.of(context).size.width;
    double kheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          height: kheight * 0.040,
          child: Image.asset("assets/images/Google_Gemini-fulllogo.png", fit: BoxFit.contain),
        ),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundImage: NetworkImage(user!.photoURL!),
            radius: 15,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MessagesList(
                  userId: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
              SizedBox(height: kheight * 0.16),
            ],
          ),
          Column(
            children: [
              Spacer(),
              if (_messageController.text.isEmpty && image == null)
                Container(
                  height: kheight * 0.066, // Adjust height as needed
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => sendMessage(predefinedMessage: _suggestions[index]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _suggestions[index],
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.deepPurple, Colors.purpleAccent.shade400, Colors.deepOrangeAccent, Colors.redAccent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (image != null)
                            Stack(
                              children: [
                                Image.file(
                                  File(image!.path),
                                  height: kheight * 0.1,
                                  width: kwidth * 0.2,
                                ),
                                Positioned(
                                  top: 3,
                                  right: -1,
                                  child: InkWell(
                                    onTap: _removeImage,
                                    child: Container(
                                      height: kheight * 0.025,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  maxLines: 6,
                                  minLines: 1,
                                  scrollController: _scrollController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Enter here",
                                    hintStyle: TextStyle(color: Colors.black45),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                  onChanged: (text) {
                                    setState(() {
                                      isButtonDisabled = text.isEmpty && image == null;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.black),
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
                                    onPressed: () => _pickImage(ImageSource.camera),
                                  ),
                                  IconButton(
                                    icon: isLoading
                                        ? const CircularProgressIndicator(color: Colors.black54)
                                        : const Icon(Icons.send_rounded, color: Colors.black),
                                    onPressed: isButtonDisabled ? null : () => sendMessage(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
