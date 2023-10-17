import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_payment/pages/bottom_nav_bar.dart';
import 'package:one_payment/utilities/elevated_button.dart';
import 'package:one_payment/utilities/text_input_decoration.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TransferMoneyPage extends StatefulWidget {
  const TransferMoneyPage({Key? key}) : super(key: key);

  @override
  State<TransferMoneyPage> createState() => _TransferMoneyPageState();
}

class _TransferMoneyPageState extends State<TransferMoneyPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();
  String? selected;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('banks').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Map<String, dynamic>> banksData = snapshot.data!.docs
                .map((doc) => {
                      'id': doc.id,
                      'imageUrl': doc['imageUrl'],
                      'name': doc['name'],
                    })
                .toList();
            banksData.sort((a, b) => a['name'].compareTo(b['name']));
            return SafeArea(
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: GestureDetector(
                            onTap: () {
                              nextScreenReplace(context, const BottomNavBar());
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 50, right: 50),
                          child: Text(
                            'Send Money',
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        margin: const EdgeInsets.only(top: 25),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.green),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton2(
                              isDense: true,
                              hint: Text(
                                'Select Bank',
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontSize: 20,
                                ),
                              ),
                              value: selected,
                              onChanged: (value) {
                                setState(() {
                                  selected = value.toString();
                                });
                              },
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              items: banksData
                                  .where((item) =>
                                      item['name'].toLowerCase().contains(
                                          searchController.text
                                              .toLowerCase()) ||
                                      searchController.text.isEmpty)
                                  .map((item) {
                                return DropdownMenuItem(
                                  value: item['name'].toString(),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        item['imageUrl'].toString(),
                                        width: 25,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Text(item['name'].toString()),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              dropdownSearchData: DropdownSearchData(
                                searchController: searchController,
                                searchInnerWidgetHeight: 55,
                                searchInnerWidget: Container(
                                  height: 60,
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 4,
                                    right: 8,
                                    left: 8,
                                  ),
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    expands: true,
                                    maxLines: null,
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      suffixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.greenAccent,
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      hintText: 'Search For Bank Name',
                                      hintStyle: GoogleFonts.poppins(),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                searchMatchFn: (item, searchValue) {
                                  return item.value
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchValue.toLowerCase());
                                },
                              ),
                              //clear the search value on close
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {
                                  searchController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Account Number',
                          labelStyle: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                          ),
                          suffixIcon: GestureDetector(
                            child: const Icon(
                              Icons.format_list_numbered_outlined,
                              color: Colors.greenAccent,
                            ),
                            onTap: () {},
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                        validator: (val) {
                          if (val!.isNotEmpty) {
                            return null;
                          } else {
                            return "Field cannot be empty";
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Amount',
                          labelStyle: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                          ),
                          suffixIcon: GestureDetector(
                            child: const Icon(
                              Icons.money,
                              color: Colors.greenAccent,
                            ),
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Narration',
                          labelStyle: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                        validator: (val) {
                          if (val!.isNotEmpty) {
                            return null;
                          } else {
                            return "Field cannot be empty";
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButtonPage(
                      text: 'Send',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
