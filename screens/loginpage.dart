import 'package:cabrider/brand_colors.dart';
import 'package:cabrider/screens/mainpage.dart';
import 'package:cabrider/screens/registrationpage.dart';
import 'package:cabrider/widgets/ProgressDialog.dart';
import 'package:cabrider/widgets/TaxiButton.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {

  static const String id= 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth= FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
        content: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void login() async{

    showDialog(
      barrierDismissible: false,
      context: context,
      //builder is use because ProgressDialog is custome widget
      builder: (BuildContext context)=> ProgressDialog('Logging You In...',),
    );

    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email:emailController.text,
      password: passwordController.text,
    ).catchError((ex){

      Navigator.pop(context);
      PlatformException thisEx=ex;
//      showSnackBar(thisEx.message);
      showSnackBar("Invalid Credentials");
    })).user;

    //if login successful

    if(user!=null){
        //verify login

      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/${user.uid}');

      userRef.once().then((DataSnapshot snapshot)=>{
        if(snapshot.value !=null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false)
        }
      });

    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70,
                ),
                Image(
                    alignment: Alignment.center,
                    height: 100.0,
                    width: 100.0,
                    image: AssetImage('images/logo.png'),),
                SizedBox(height: 40),
                Text(
                  'Sign In As A Rider',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),

                Padding(
                  padding:  EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.0,
                          )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 10,),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )
                        ),
                        style: TextStyle(fontSize: 14),
                      ),

                      SizedBox(height: 40,),

                      TaxiButton(
                        title:'LOGIN',
                        color: BrandColors.colorGreen,
                        onPressed: ()async{

                          var connectivityResult = await Connectivity().checkConnectivity();

                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet Connectivity');
                            return;
                          }

                          if(!emailController.text.contains('@')){
                            showSnackBar('Please enter a valid email address');
                            return;
                          }

                          if(passwordController.text.length <8){
                            showSnackBar('Password must be atleast 8 characters');
                            return;
                          }

                          login();

                        },

                      ),
                    ],
                  ),
                ),

                FlatButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                  },
                  child: Text('Don\'t have an account? Sign Up Here'),),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

