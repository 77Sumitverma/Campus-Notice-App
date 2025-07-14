import 'package:campus_notice_app/Screens/Navigation_bar/Add%20updates%20Screen/add_updates.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Navigation_bar/Home Screen/Home_page.dart';
import 'ForgotPassword_screen.dart';
import 'package:get_storage/get_storage.dart';

class SignUp_Screen extends StatefulWidget {
  @override
  _SignUp_Screen createState() => _SignUp_Screen();
}

class _SignUp_Screen extends State<SignUp_Screen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController uidController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    mobileController.dispose();
    //uidController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildTextField(String hint, bool obscureText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void signUp(BuildContext context) async {
    try {
      String customUid = uidController.text.trim();

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      String role = customUid == "lovishv498@gmail.com" ? "admin" : "user";

      // Save to Firestore
      await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'custom_uid': customUid,
        'email': emailController.text.trim(),
        'role': role,
        'createdAt': Timestamp.now(),
      });
      GetStorage().write('userName', nameController.text.trim());
      // 🔀 Redirect based on role
      if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${e.toString()}")),
      );
    }
  }


  // ✅ GOOGLE SIGN-IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      // ✅ Define your admin email (replace with your real one)
      const adminEmail = "lovishv498@gmail.com";

      // 🔥 Check if user exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      String role = "User";

      // 🔁 If user doesn't exist, create new with role
      if (!userDoc.exists) {
        if (user.email == adminEmail) {
          role = "admin";
        }

        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'mobile': '',
          'custom_uid': '',
          'createdAt': Timestamp.now(),
          'signInMethod': 'google',
          'role': role,
        });
      } else {
        // User exists → get role from Firestore
        role = (userDoc.data() as Map<String, dynamic>)['role'] ?? "User";
      }

      // ✅ Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            elevation: 40,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 20),
                    buildTextField("Full Name", false, nameController),
                    buildTextField("Mobile Number", false, mobileController,
                        keyboardType: TextInputType.phone),
                    //buildTextField("Unique ID", false, uidController),
                    buildTextField("Email", false, emailController,
                        keyboardType: TextInputType.emailAddress),
                    buildTextField("Password", true, passwordController),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => signUp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: Text("Sign Up",
                          style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 15),
                    Text("OR", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => signInWithGoogle(context),
                      icon: Icon(Icons.g_mobiledata, color: Colors.blue),
                      label: Text("Sign Up with Google",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
