import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padshala/common/favourites/favoutiresdetails.dart';
import 'package:padshala/homepage.dart';
import 'package:padshala/user_orders.dart';
import 'package:padshala/whatsapp_support.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String name = "";
  String phoneNumber = "";
  String profilePic = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? user!.displayName ?? "No Name";
          phoneNumber = user!.phoneNumber ?? "No Phone Number";
          profilePic = userDoc['profilePic'] ?? user!.photoURL ?? "";
        });
      }
    }
  }

  void _showEditProfilePopup() {
    TextEditingController nameController = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _updateProfilePicture,
                child: CircleAvatar(
                  radius: 40,
                 backgroundImage: profilePic.isNotEmpty
                      ? NetworkImage(profilePic)
                      : AssetImage("assets/images/chichiisplash.png") as ImageProvider,
                  child: Icon(Icons.camera_alt, size: 25, color: Colors.white70),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateUserProfile(nameController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

 Future<void> _updateProfilePicture() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    String fileName = user!.uid;
    Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$fileName.jpg');
    UploadTask uploadTask = storageRef.putFile(imageFile);
    await uploadTask.whenComplete(() async {
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        profilePic = downloadUrl;
      });
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'profilePic': downloadUrl});
    });
  }
}


  Future<void> _updateUserProfile(String newName) async {
    setState(() {
      name = newName;
    });

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'name': newName});
  }
void _showConfirmDialog(String action) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm $action"),
          content: Text("Are you sure you want to $action?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (action == "logout") {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                }
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text("My Profile"), centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
            Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
            },
          ),
        ),
        body: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[300],
             backgroundImage: profilePic.isNotEmpty
        ? NetworkImage(profilePic)
        : AssetImage("assets/images/chichiisplash.png") as ImageProvider,
      ),
            SizedBox(height: 10),
            Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             Text(phoneNumber, style: TextStyle(color: Colors.grey[600])),
                  Divider(),
             Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _showEditProfilePopup,
                        child: Text("EDIT PROFILE", style: TextStyle(color: Colors.blue)),
                      ),
                      Container(width: 1, height: 20, color: Colors.grey), // Fixed Divider
                TextButton(
                  onPressed: () {}, 
                  child: Text("ADD NEW NUMBER", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Card(
                margin: EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                  profileOption("My Favorite", Icons.favorite,onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavouritesDetails()),
                    );
                  }),
                  profileOption("My Address", Icons.location_on,),
                  profileOption("My Orders", Icons.list_alt, onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MyOrdersScreen()),
  );
}),
                profileOption("Support", Icons.support, onTap: WhatsappSupportButton.launchWhatsApp),
                  profileOption("Logout", Icons.exit_to_app, color: Colors.red, onTap: () => _showConfirmDialog("logout")),
              ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileOption(String title, IconData icon, {Color color = Colors.black, Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}
