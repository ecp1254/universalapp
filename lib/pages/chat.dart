import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:one_payment/pages/user_management_page.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

import 'package:flutter_tawkto/flutter_tawk.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              nextScreen(context, const UserManagementPage());
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.black,
          ),
          title: const Text('UniversalApp Support'),
          backgroundColor: Colors.green,
          elevation: 0,
        ),
        body: Tawk(
          directChatLink:
              'https://tawk.to/chat/652e5841a84dd54dc48206d9/1hcughgj2',
          visitor: TawkVisitor(
            name: ' ${user?.displayName} ',
            email: currentUser.email!,
          ),
          onLoad: () {
            ('Hello Dear!');
          },
          onLinkTap: (String url) {
            (url);
          },
          placeholder: const Center(
            child: Text('Loading...'),
          ),
        ),
      ),
    );
  }
}
