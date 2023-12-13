import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KryptoGO V1 Migrate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFC211)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'KryptoGO V1 Migrate'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();
  bool decrypting = false;
  String decryptedMnemonic = '';

  Future<SecretKey> generateKeyOld(Uint8List salt, Uint8List passphrase) async {
    // Ref: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
    final pbkdf2 =
        Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 310000, bits: 128);
    return await pbkdf2.deriveKey(
        secretKey: SecretKey(passphrase), nonce: salt);
  }

  Future<List<String>> decryptMnemonic(
      String encryptedMnemonic, String salt, String passphrase) async {
    final key = await generateKeyOld(Uint8List.fromList(hex.decode(salt)),
        Uint8List.fromList(passphrase.codeUnits));
    final algorithm = AesCbc.with128bits(macAlgorithm: Hmac.sha256());

    final clearText = await algorithm.decrypt(
      SecretBox.fromConcatenation(base64Decode(encryptedMnemonic),
          nonceLength: 16, macLength: 32),
      secretKey: key,
    );
    return String.fromCharCodes(clearText).split(' ');
  }

  Uint8List generateSalt(int length) {
    final generator = Random.secure();
    final salt = Uint8List(length);
    for (var i = 0; i < salt.length; i++) {
      salt[i] = generator.nextInt(255);
    }
    return salt;
  }

//   Future<List<String>> encryptMnemonic(
//       String mnemonic, String passphrase, Uint8List salt) async {
//     final key = await generateKeyOld(
//         Uint8List.fromList(salt), Uint8List.fromList(passphrase.codeUnits));
//     final algorithm = AesCbc.with128bits(macAlgorithm: Hmac.sha256());
//
//     final secretBox = await algorithm.encrypt(
//       mnemonic.codeUnits,
//       secretKey: key,
//     );
//     return [base64Encode(secretBox.concatenation()), hex.encode(salt)];
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image.asset(
            'assets/logo.png',
            width: 200,
            height: 200,
          ),
          Text(
            'KryptoGO V1 Migrate',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 50,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    const salt = "4dbe735e73abbe9fdf6508284e0db017";
                    const encryptedMnemonic =
                        'H9kF2JgdWvRbF0mvMCTCRcURcWW7yZkzwd5AUuEYRgcC0O4OXofmPZFRNMgQXaYJLhVeZH4ORM0OSEMICPDQt9d+5F0NxqJUIJT+uIoZFM+ohh1nrtGBJ6FguzeXO4/JyVaCxadBz5nX5V3RhPgtcsKFJN5gnS4FQRmlkTdRN04=';
                    print(controller.text);
                    decryptedMnemonic = (await decryptMnemonic(
                            encryptedMnemonic, salt, controller.text))
                        .join(' ');
                    debugPrint(
                        '=======decryptedMnemonic : $decryptedMnemonic=========');
                    setState(() {});
                  } catch (e) {
                    decryptedMnemonic = '密碼錯誤';
                    setState(() {});

                    debugPrint('=======e : $e=========');
                  }
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC211),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child:
                      const Text('解碼', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          if (controller.text.isNotEmpty && decryptedMnemonic != '密碼錯誤')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  decryptedMnemonic,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: decryptedMnemonic));
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            )
          else
            Text(
              decryptedMnemonic,
              textAlign: TextAlign.center,
            )
          // Button
        ],
      ),
    );
  }
}
