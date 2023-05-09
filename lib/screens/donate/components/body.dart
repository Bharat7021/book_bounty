import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:book_bounty/main.dart';
import 'package:book_bounty/utils.dart';
import 'package:csc_picker/csc_picker.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

String? stateValue = "", cityValue = "", countryValue = "";
String imageURL = '';
String selectedImagePath = '';

class _BodyState extends State<Body> {
  _BodyState() {
    selectedCondition = conditions[0];
    selectedGenre = genres[0];
  }
  final conditions = ["New", "Good", "Better", "Poor"];
  final genres = [
    'Art',
    'Biography',
    'Business',
    'Chick Lit',
    'Children',
    'Christian',
    'Classics',
    'Comics',
    'Contemporary',
    'Cookbooks',
    'Crime',
    'Ebooks',
    'Fantasy',
    'Fiction',
    'Gay and Lesbian',
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
  final isbnController = TextEditingController();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final genreController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final conditionController = TextEditingController();
  final locationController = TextEditingController();
  String? selectedCondition = '', selectedGenre = '';
  @override
  void dispose() {
    isbnController.dispose();
    titleController.dispose();
    authorController.dispose();
    genreController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    conditionController.dispose();
    locationController.dispose();

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
      'isbn': isbnController.text.trim(),
      'title': titleController.text.trim(),
      'author': authorController.text.trim(),
      'genre': selectedGenre,
      'description': descriptionController.text.trim(),
      'image': imageURL,
      'condition': selectedCondition,
      'location': "$stateValue, $cityValue",
      'donated_by': FirebaseAuth.instance.currentUser!.uid,
      'applied_by': [],
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
          vertical: 12,
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 22),
              child: Text(
                "Donate Book",
                style: TextStyle(
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
                      controller: isbnController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF66ffee), width: 2)),
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.green,
                        ),
                        labelText: 'ISBN',
                        hintText: 'ISBN',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF66ffee), width: 2)),
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.green,
                        ),
                        labelText: 'Title',
                        hintText: 'Title',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: authorController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF66ffee), width: 2)),
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.green,
                        ),
                        labelText: 'Authors',
                        hintText: 'Authors',
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
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF66ffee), width: 2)),
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.green,
                        ),
                        labelText: 'Genre',
                        hintText: 'Genre',
                      ),
                    ),
                    // TextFormField(
                    //   controller: genreController,
                    //   textInputAction: TextInputAction.next,
                    //   decoration: const InputDecoration(
                    //     border: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.black)),
                    //     focusedBorder: OutlineInputBorder(
                    //         borderSide:
                    //             BorderSide(color: Color(0xFF66ffee), width: 2)),
                    //     prefixIcon: Icon(
                    //       Icons.book,
                    //       color: Colors.green,
                    //     ),
                    //     labelText: 'Genre',
                    //     hintText: 'Genre',
                    //   ),
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF66ffee), width: 2)),
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.green,
                        ),
                        labelText: 'Description',
                        hintText: 'Description',
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
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF66ffee), width: 2)),
                        prefixIcon: Icon(
                          Icons.book,
                          color: Colors.green,
                        ),
                        labelText: 'Condition',
                        hintText: 'Condition',
                      ),
                    ),
                    // TextFormField(
                    //   controller: conditionController,
                    //   textInputAction: TextInputAction.next,
                    //   decoration: const InputDecoration(
                    //     border: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.black)),
                    //     focusedBorder: OutlineInputBorder(
                    //         borderSide:
                    //             BorderSide(color: Color(0xFF66ffee), width: 2)),
                    //     prefixIcon: Icon(
                    //       Icons.book,
                    //       color: Colors.green,
                    //     ),
                    //     labelText: 'Condition',
                    //     hintText: 'Condition',
                    //   ),
                    // ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CSCPicker(
                      showStates: true,
                      showCities: true,
                      defaultCountry: CscCountry.India,
                      disableCountry: true,
                      onCountryChanged: (value) {
                        setState(() {
                          ///store value in country variable
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
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      selectedImagePath == ''
                          ? Image.asset(
                              'assets/images/image_placeholder.png',
                              height: 200,
                              width: 200,
                              fit: BoxFit.fill,
                            )
                          : Image.file(
                              File(selectedImagePath),
                              height: 200,
                              width: 200,
                              fit: BoxFit.fill,
                            ),
                      const Text(
                        'Select Image',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(20)),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(
                                      fontSize: 14, color: Colors.white))),
                          onPressed: () async {
                            selectImage();
                            setState(() {});
                          },
                          child: const Text('Select')),
                      const SizedBox(height: 10),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: donate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[500],
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
                borderRadius: BorderRadius.circular(20.0)), //this right here
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
