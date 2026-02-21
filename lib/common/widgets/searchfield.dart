import 'package:flutter/material.dart';
import 'package:shop_app/data/repositories/authentication_repo/auth_repository.dart';
import 'package:shop_app/screens/home_screen.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_app/screens/shopdetailsscreen.dart';
import 'package:shop_app/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/shop.dart';

class Searchfield extends StatefulWidget {
  const Searchfield({super.key});

  @override
  State<Searchfield> createState() => _SearchfieldState();
}

class _SearchfieldState extends State<Searchfield> {
  TextEditingController _searchController = TextEditingController();
  final userEmail = AuthRepository().currentUser?.email ?? '';
  String _searchText = '';
  SpeechToText _speechToText = SpeechToText();
  // ignore: unused_field
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _requestMicrophonePermission();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  /// Initialize speech-to-text
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Start speech recognition
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Stop speech recognition
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
    });
  }

  /// Request microphone permission
  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ))),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search shops by name',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                    icon: Icon(_speechToText.isNotListening
                        ? Icons.mic_off
                        : Icons.mic),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Shop>>(
        stream: firestoreService.getShopsByOwnerEmail(userEmail),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final shops = snapshot.data ?? [];
          final filteredShops = shops
              .where((shop) => shop.shopename
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
              .toList();

          if (filteredShops.isEmpty) {
            return const Center(child: Text('No matching shops found.'));
          }

          return ListView.builder(
            itemCount: filteredShops.length,
            itemBuilder: (context, index) {
              final shop = filteredShops[index];
              return ListTile(
                title: Text(shop.shopename),
                subtitle: Text(shop.shopaddress),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShopDetailsScreen(shop: shop)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
