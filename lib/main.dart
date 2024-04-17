import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearching = false;

  Map<String, dynamic>? tagData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Manager Impl'),
      ),
      body: Center(
        child: Builder(builder: (context) {
          if (tagData != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Data: $tagData"),
                ElevatedButton(
                  onPressed: readNFC,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Try again'),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() => tagData == null),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Home'),
                  ),
                )
              ],
            );
          }

          if (isSearching) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.nfc, size: 48),
                Text("Searching for NFC tag"),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("NFC reading example"),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: readNFC,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Try me'),
                ),
              ),
              const SizedBox(height: 64),
              const Text("NFC writing example"),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: readNFC,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Try me'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void readNFC() async {
    setState(() {
      tagData = null;
    });

    bool isAvailable = await NfcManager.instance.isAvailable();

    if (isAvailable) {
      setState(() {
        toggleIsSearching();
      });

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          setState(() {
            tagData = tag.data;

            toggleIsSearching();
          });
        },
      );
    } else {
      showUnavailableErrorDialog();
    }
  }

  void writeNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (isAvailable) {
      toggleIsSearching();

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        try {
          NdefMessage message = NdefMessage([NdefRecord.createText('Hello, NFC!')]);
          await Ndef.from(tag)?.write(message);

          NfcManager.instance.stopSession();

          toggleIsSearching();

          showSuccessDialog();
        } catch (_) {
          showWritingError();
        }
      });
    } else {
      showUnavailableErrorDialog();
    }
  }

  void showWritingError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error writting to NFC"),
        content: const Text("Check if the tag supports NDEF"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ok"))],
      ),
    );
  }

  void showUnavailableErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Uncapable of reading"),
        content: const Text("Check if the device has NFC available"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ok"))],
      ),
    );
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Operation Complete"),
        content: const Text("Data written in the NFC tag successfully"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ok"))],
      ),
    );
  }

  void toggleIsSearching() {
    isSearching = !isSearching;
  }
}
