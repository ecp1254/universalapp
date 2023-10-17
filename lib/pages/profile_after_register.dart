// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/models.dart';

import 'package:one_payment/utilities/text_box.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';

class ProfilesAfterRegistration extends StatefulWidget {
  const ProfilesAfterRegistration({super.key});

  @override
  State<ProfilesAfterRegistration> createState() =>
      _ProfilesAfterRegistrationState();
}

class _ProfilesAfterRegistrationState extends State<ProfilesAfterRegistration> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  FirebaseAuth auth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection('user');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _imageFile;
  // ignore: unused_field
  String? _imageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  // ignore: unused_element
  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  // ignore: unused_element
  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      final email = currentUser.email!;
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$email.jpg');

      await storageRef.putFile(_imageFile!);

      final downloadUrl = await storageRef.getDownloadURL();

      // Update user document with the image URL
      await usersCollection.doc(email).update({
        'image_url': downloadUrl,
      });

      setState(() {
        _imageUrl = downloadUrl;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    final email = auth.currentUser!.email;
    final userDoc = await _firestore.collection('user').doc(email).get();
    final userData = userDoc.data();
    final imageUrl = userData?['image_url'];

    setState(() {
      _imageUrl = imageUrl;
    });
  }

  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    _fetchUserProfile();
    super.initState();
  }

  void saveProfile() async {
    nextScreenReplace(context, const BottomNavBar());
  }

  Future<void> editField(String field) async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
          ),
          onChanged: (value) {
            setState(() {
              newValue = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              String formattedField = formatFieldName(field);
              log('formattedField $formattedField');
              if (newValue.trim().isNotEmpty) {
                await usersCollection
                    .doc(currentUser.email)
                    .update({formattedField: newValue});
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String formatFieldName(String input) {
    // Split the input string by spaces
    List<String> words = input.split(' ');

    // Capitalize the first word and convert the rest to lowercase
    String formatted = words[0].toLowerCase() +
        words
            .skip(1)
            .map((word) =>
                word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join('');

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Welcome to your world of Endless Banking.',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      child: Stack(
                        children: [
                          if (_imageUrl != null)
                            CircleAvatar(
                              radius: 60.0,
                              backgroundImage: NetworkImage(_imageUrl!),
                            )
                          else
                            const CircleAvatar(
                              radius: 65.0,
                              backgroundImage: NetworkImage(
                                  'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProfileElevatedButton(
                          text: 'Select Image',
                          onPressed: () async {
                            await _pickImage();
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 22),
                  ),
                  TextBox(
                      text: userData['name'],
                      sectionName: 'Name',
                      onPressed: () => editField('Name')),
                  TextBox(
                      text: userData['dateOfBirth'],
                      sectionName: 'DOB',
                      onPressed: () => editField('Date Of Birth')),
                  TextBox(
                      text: userData['gender'],
                      sectionName: 'Gender',
                      onPressed: () => editField('Gender')),
                  TextBox(
                      text: userData['country'],
                      sectionName: 'Country',
                      onPressed: () => editField('Country')),
                  TextBox(
                      text: userData['state'],
                      sectionName: 'State',
                      onPressed: () => editField('State')),
                  TextBox(
                      text: userData['address'],
                      sectionName: 'Address',
                      onPressed: () => editField('Address')),
                  TextBox(
                      text: userData['phoneNumber'],
                      sectionName: 'Phone Number',
                      onPressed: () => editField('Phone Number')),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButtonPage(
                        text: 'Next',
                        onPressed: () {
                          nextScreenReplace(context, const BottomNavBar());
                        }),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('error${snapshot.error}'),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

//                                    'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), color: Colors.grey[100]),
        child: Icon(
          icon,
          color: const Color.fromARGB(255, 10, 124, 16),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w500, color: textColor),
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey[100]),
              child: const Icon(
                Icons.arrow_right,
                size: 20,
                color: Color.fromARGB(255, 10, 124, 16),
              ),
            )
          : null,
    );
  }
}
