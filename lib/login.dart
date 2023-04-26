import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:timely/agenda.dart';
import 'package:timely/controllers/account_controller.dart';
import 'package:timely/intro_screen.dart';

/// Calls on the widgets created for login
/// Using some css type styling to make sure everything is aligned as it should be
class Login extends StatelessWidget {
  const Login({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Flutter layout demo'),
      // ),
      body: Column(
        children: const [
          Spacer(),
          Text(
            'Timely',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          MyStatefulWidget(), //All the login options
          Spacer(),
        ],
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => MyCustomForm();
}

class MyCustomForm extends State<MyStatefulWidget> {
  bool passHidden = true;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        //Setting the fonts/colors/text for the text boxes of username and password
        const Text(
          'Login with one of the following options',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 5),
          //The icon button that triggers logging in to google with the help of firebase
          //Once user is logged in then is redirected to the agenda view
          IconButton(
              icon: const Icon(FontAwesome.google, color: Colors.red, size: 32),
              tooltip: 'Login with Google',
              onPressed: () {
                AccountController().signUpOrLinkAccount('google.com').then((_) {
                  navigateToNextScreen(context);
                });
              }),

          const Spacer(flex: 2),

          //Place holder button for logging in with apple
          IconButton(
            icon: Icon(FontAwesome.apple,
                color: Theme.of(context).iconTheme.color, size: 32),
            tooltip: 'Login with Apple',
            onPressed: () {
              AccountController().signUpOrLinkAccount('apple.com').then((_) {
                navigateToNextScreen(context);
              });
            },
          ),
          const Spacer(flex: 2),
          IconButton(
            icon:
                const Icon(FontAwesome.microsoft, color: Colors.cyan, size: 32),
            tooltip: 'Login with Microsoft',
            onPressed: () => AccountController()
                .signUpOrLinkAccount('microsoft.com')
                .then((_) {
              navigateToNextScreen(context);
            }),
          ),

          const Spacer(flex: 5)
        ]),
      ],
    );
  }

  void navigateToNextScreen(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      if (AccountController().firstTimeUser == true) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const IntroScreen()));
        Fluttertoast.showToast(
            msg:
                "Welcome to timely ${FirebaseAuth.instance.currentUser!.email!}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const AgendaWidget(view: 8)));
      }
    } else {
      Fluttertoast.showToast(
          msg: "Unable to login, please try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
