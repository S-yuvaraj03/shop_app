import 'package:google_generative_ai/google_generative_ai.dart';

class Chat {
  final List<Content> history;

  Chat({required this.history});

  Future<GenerateContentResponse> sendMessage(GenerativeModel model, Content content) async {
    // Append the new user message to the history
    history.add(content);

    // Generate the response from the model
    final response = await model.generateContent(history);

    // Append the model's response to the history
    history.add(Content.text(response.text!));

    return response;
  }
}
