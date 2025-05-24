import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/data/repositories/storage_repo/storage.repository.dart';
import 'package:shop_app/features/shop/model/message.dart';
import 'package:uuid/uuid.dart';

import '/extensions/extensions.dart';

@immutable
class ChatRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  //! This method sends an image alongside the text
  Future sendMessage({
    required String apiKey,
    required XFile? image,
    required String promptText,
  }) async {
    // Define your model
    final textModel = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    final imageModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final userId = _auth.currentUser!.uid;
    final sentMessageId = const Uuid().v4();

    Message message = Message(
      id: sentMessageId,
      message: promptText,
      createdAt: DateTime.now(),
      isMine: true,
    );

    if (image != null) {
      // Save image to Firebase Storage and get download url
      final downloadUrl = await StorageRepository().saveImageToStorage(
        image: image,
        messageId: sentMessageId,
      );

      message = message.copyWith(
        imageUrl: downloadUrl,
      );
    }

    // Save Message to Firebase
    await _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .doc(sentMessageId)
        .set(message.toMap());

    // Create a response
    GenerateContentResponse response;

    try {
      if (image == null) {
        // Make a text only request to Gemini API
        response = await textModel.generateContent([Content.text(promptText)]);
      } else {
        // convert it to Uint8List
        final imageBytes = await image.readAsBytes();

        // Define your parts
        final prompt = TextPart(promptText);
        final mimeType = image.getMimeTypeFromExtension();
        final imagePart = DataPart(mimeType, imageBytes);

        // Make a multi-model request to Gemini API
        response = await imageModel.generateContent([
          Content.multi([
            prompt,
            imagePart,
          ])
        ]);
      }

      final responseText = response.text;

      // Save the response in Firebase
      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      // Save Message to Firebase
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! Send Text Only Prompt
  Future sendTextMessage({
    required String textPrompt,
    required String apiKey,
  }) async {
    try {
      // Define your model
      final textModel = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

      final userId = _auth.currentUser!.uid;
      final sentMessageId = const Uuid().v4();

      Message message = Message(
        id: sentMessageId,
        message: textPrompt,
        createdAt: DateTime.now(),
        isMine: true,
      );

      // Save Message to Firebase
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(sentMessageId)
          .set(message.toMap());

      // Make a text only request to Gemini API and save the response
      final response =
          await textModel.generateContent([Content.text(textPrompt)]);

      final responseText = response.text;

      // Save the response in Firebase
      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      // Save Message to Firebase
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //! Start Chat and Send Initial Messages
  Future<void> startChatAndSendMessage({
    required String apiKey,
    required String initialText,
    required String promptText,
  }) async {
    // Define your model
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

    // Start chat with initial history
    final chat = model.startChat(history: [
      Content.text(initialText),
      Content.model([TextPart('Great to meet you. What would you like to know?')])
    ]);

    // Create and send a new message
    var content = Content.text(promptText);
    var response = await chat.sendMessage(content);
    print(response.text);

    final userId = _auth.currentUser!.uid;

    // Save initial message to Firebase
    final initialMessageId = const Uuid().v4();
    Message initialMessage = Message(
      id: initialMessageId,
      message: initialText,
      createdAt: DateTime.now(),
      isMine: true,
    );
    await _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .doc(initialMessageId)
        .set(initialMessage.toMap());

    // Save prompt message to Firebase
    final promptMessageId = const Uuid().v4();
    Message promptMessage = Message(
      id: promptMessageId,
      message: promptText,
      createdAt: DateTime.now(),
      isMine: true,
    );
    await _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .doc(promptMessageId)
        .set(promptMessage.toMap());

    // Save response message to Firebase
    final responseMessageId = const Uuid().v4();
    Message responseMessage = Message(
      id: responseMessageId,
      message: response.text!,
      createdAt: DateTime.now(),
      isMine: false,
    );
    await _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .doc(responseMessageId)
        .set(responseMessage.toMap());
  }
}
