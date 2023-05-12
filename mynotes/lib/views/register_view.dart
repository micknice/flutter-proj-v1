import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}): super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'),
       ),
      body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter email here',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter password here',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {                  
                    final email = _email.text;
                    final password = _password.text;
                    try {
                    final userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword (
                      email: email,
                      password: password,
                    );
                    devtools.log(userCredential.toString());            
    
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                      devtools.log('ERROR:');
                      devtools.log(e.code.toString());
    
                      } else if (e.code == 'email-already-in-use'){
                        devtools.log('ERROR:');
                        devtools.log(e.code.toString());
                      } else if (e.code == 'invalid-email'){
                        devtools.log('ERROR:');
                        devtools.log(e.code.toString());
                      }
    
                    }
                    
                  },              
                child: const Text('Register'),
                ),
                TextButton(onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', 
                    (route) => false);
                }, child: const Text('Already Registered? Login here!'),
                )
              ],
            ),
    );
  }
}