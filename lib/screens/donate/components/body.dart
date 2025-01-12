import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:book_bounty/main.dart';
import 'package:book_bounty/utils.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  _BodyState() {
    selectedCondition = conditions[0];
    selectedGenre = genres[0];
  }
  final conditions = ["New", "Good", "Fair", "Poor"];
  final genres = [
    'Art',
    'Autobiography',
    'Biography',
    'Business',
    'Children',
    'Classics',
    'Comics',
    'Contemporary',
    'Cookbooks',
    'Crime',
    'Fantasy',
    'Fiction',
    'Graphic Novels',
    'Historical Fiction',
    'History',
    'Horror',
    'Humor and Comedy',
    'Manga',
    'Memoir',
    'Music',
    'Mystery',
    'Nonfiction',
    'Paranormal',
    'Philosophy',
    'Poetry',
    'Psychology',
    'Religion',
    'Romance',
    'Science',
    'Science Fiction',
    'Self Help',
    'Suspense',
    'Spirituality',
    'Sports',
    'Thriller',
    'Travel',
    'Young Adult'
  ];

  final _formKey = GlobalKey<FormState>();
  String imageURL = '';
  String selectedImagePath = '';
  String? stateValue = "", cityValue = "", countryValue = "";
  String? selectedCondition = '', selectedGenre = '';
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    descriptionController.dispose();
    imageController.dispose();

    super.dispose();
  }

  Future<void> donate() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);
    try {
      await referenceImageToUpload.putFile(File(selectedImagePath));
      imageURL = await referenceImageToUpload.getDownloadURL();
    } catch (e) {
      Utils.showSnackBar("Image not uploaded.");
    }

    final myCollectionRef = FirebaseFirestore.instance.collection('book');

    final myFields = {
      'title': titleController.text.trim(),
      'author': authorController.text.trim(),
      'genre': selectedGenre,
      'description': descriptionController.text.trim(),
      'image': imageURL,
      'condition': selectedCondition,
      'city': '$cityValue',
      'state': '$stateValue',
      'donated_by': FirebaseAuth.instance.currentUser!.uid,
      'applied_by': '',
    };

    try {
      await myCollectionRef.add(myFields);
    } catch (error) {
      Utils.showSnackBar("Coudn't donate book.");
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 22),
              child: Text(
                "Donate Book",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xff383838),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.blueGrey,
                        ),
                        // labelText: 'Title',
                        hintText: 'Title',
                        // labelStyle: TextStyle(color: Colors.white70),
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: authorController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xff383838),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blueGrey,
                        ),
                        // labelText: 'Author',
                        hintText: 'Author',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xff383838),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.description_outlined,
                          color: Colors.blueGrey,
                        ),
                        // labelText: 'Description',
                        hintText: 'Description',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField(
                      value: selectedGenre,
                      items: genres
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (val) {},
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xff383838),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Genre',
                          labelStyle: TextStyle(color: Colors.white70)
                          // hintText: 'Genre',
                          // hintStyle: TextStyle(color: Colors.white70),
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DropdownButtonFormField(
                      value: selectedCondition,
                      items: conditions
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (val) {},
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xff383838),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.book,
                            color: Colors.blueGrey,
                          ),
                          labelText: 'Condition',
                          labelStyle: TextStyle(color: Colors.white70)
                          // hintText: 'Condition',
                          // hintStyle: TextStyle(color: Colors.white70)
                          ),
                    ),
                  ),
                  CSCPicker(
                    showStates: true,
                    showCities: true,
                    defaultCountry: CscCountry.India,
                    disableCountry: true,
                    selectedItemStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    dropdownDecoration: const BoxDecoration(
                      color: Color(0xff383838),
                    ),
                    disabledDropdownDecoration: const BoxDecoration(
                      color: Color(0xff383838),
                    ),
                    onCountryChanged: (value) {
                      setState(() {
                        countryValue = value;
                      });
                    },
                    onStateChanged: (value) {
                      setState(() {
                        stateValue = value;
                      });
                    },
                    onCityChanged: (value) {
                      setState(() {
                        cityValue = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: InkWell(
                      onTap: () async {
                        selectImage();
                        setState(() {});
                      },
                      child: (selectedImagePath == '')
                          ? Image.asset(
                              'assets/images/image_placeholder.png',
                              height: 250,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImagePath),
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: donate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text("Donate"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future selectImage() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: SizedBox(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      'Select Image From !',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromGallery();
                            if (selectedImagePath != '') {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("No Image Selected !"),
                              ));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/gallery.png',
                                      height: 60,
                                      width: 60,
                                    ),
                                    const Text('Gallery'),
                                  ],
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () async {
                            selectedImagePath = await selectImageFromCamera();

                            if (selectedImagePath != '') {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("No Image Captured !"),
                              ));
                            }
                          },
                          child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/camera.png',
                                      height: 60,
                                      width: 60,
                                    ),
                                    const Text('Camera'),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  selectImageFromGallery() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 10);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }

  selectImageFromCamera() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 10);
    if (file != null) {
      return file.path;
    } else {
      return '';
    }
  }
}
