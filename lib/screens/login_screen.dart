import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFF00CDA6)]
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFF008999),
                    shape: BoxShape.circle
                  )
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                Column(
                  children: const [
                    Text(
                      "GapanTrax",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF008999),
                      )
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 10.0)),
                    Text(
                      "Contact Tracing Application of\nGapan City",
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF008999),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                ),
                const Padding(padding: EdgeInsets.only(top: 15)),
                const Spacer(),
              ],
            ),  
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(10),
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(4, 8), // changes position of shadow
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Admin Log In",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if(value == null || value.isEmpty) return "Please enter email";
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          labelText: "Email",
                          labelStyle: TextStyle(fontSize: 14)
                        )
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) {
                          if(value == null || value.isEmpty) return "Please enter password";
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 14)
                        )
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if(_formKey.currentState!.validate()) {
                            try {
                              await auth.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text
                              );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                Fluttertoast
                              } else if (e.code == 'wrong-password') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text("Invalid password.")
                                ));
                              }
                            }
                          }
                        },
                        child: const Text(
                          "LOG IN",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0)
                          ),
                          primary: const Color(0xFF008999),
                          onPrimary: Colors.white,
                          minimumSize: const Size(300, 60)
                        ),
                      )
                    )
                  ]
                ),
              )
            ),
            const Spacer()         
          ],
        )
      )
    );
  }
}