import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/http_exception.dart';
import '../providers/auth.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = 'auth-screen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: <Widget>[
        Image.network(
          'https://media.istockphoto.com/vectors/seamless-shopping-cart-colorfull-pattern-background-vector-id515964584?k=20&m=515964584&s=612x612&w=0&h=Vr9sVqr4_dGRWLFNHTKbRyN6x7OQCgdjtj-lt1WJJdY=',
          fit: BoxFit.cover,
          height: deviceSize.height,
          width: deviceSize.width,
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                    // transform: Matrix4.rotationZ(-5 * pi / 180),
                    // ..translate(-10),
                    // Since translate returns a void and I need to return a Matrix4 we use the double dots syntax ..
                    // .. calls translate on Matrix4 however it doesn't return what translate returns rather the previous statement which is a Matrix4
                    // it's called the cascade operator
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 11,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Text(
                      'My Shop',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'anton',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: const AuthCard(),
                  flex: deviceSize.width > 600 ? 2 : 1,
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  // ignore: prefer_final_fields
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    //vsync gives a pointer of the object or the widget that will change when it's on screen
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _controller, curve: Curves.fastOutSlowIn)); //between
    // _heightAnimation.addListener(() => setState(() {}));  Instead of manually managing our animation with listeners, we use a built in widget
    _opacityAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _errorMessage(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An error occured'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Ok'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      //Invalid
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false).logIn(
            _authData['email'] as String, _authData['password'] as String);
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
            _authData['email'] as String, _authData['password'] as String);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed.';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address already exists';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _errorMessage(errorMessage);
    } catch (error) {
      var errorMessage = 'Authentication failed. Please try again later.';
      _errorMessage(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((10))),
      elevation: 15,
      child: AnimatedContainer(
        // doesn't need a controller to specify what it will do it detects changes on its own and smoothly transition between them
        // AnimatedBuilder(
        // animation: _heightAnimation,
        // builder: (context, child) => Container(
        //     // the child here doesn't rebuild which is something we want since the form itself doesn't change
        //     //animatedBuilder is good to use when you only want to rebuild  a part of the widget tree and not the entire widget tree
        //     // ,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        // height: _heightAnimation.value.height,
        height: _authMode == AuthMode.signup ? 320 : 260,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.signup ? 320 : 260,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                // ignore: body_might_complete_normally_nullable
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Invalid Email!';
                  }
                },
                onSaved: (value) {
                  _authData['email'] = value as String;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: _passwordController,
                // ignore: body_might_complete_normally_nullable
                validator: (value) {
                  if (value!.isEmpty || value.length < 5) {
                    return 'Password is too short!';
                  }
                },
                onSaved: (value) {
                  _authData['password'] = value as String;
                },
              ),
              // if (_authMode == AuthMode.signup)
              AnimatedContainer(
                //we use animatedcontainer so that the space of the fadedtransition widget isn't always reserved
                // but only appears when it's on the screen
                constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.signup ? 120 : 0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.signup,
                      decoration:
                          const InputDecoration(labelText: 'Confirm password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.signup
                          // ignore: body_might_complete_normally_nullable
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords don\'t match!';
                              }
                            }
                          : null,
                      onSaved: (value) {},
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                    onPressed: _submit,
                    child:
                        Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 8)),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary),
                        textStyle: MaterialStateProperty.all(TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .button!
                                .color)))),
              TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(_authMode == AuthMode.login
                      ? 'Don\'t have an account? \n \t\t\t\t\t\t\t\t\t\t\t\t\t Sign in.'
                      : 'Already have an account? \n \t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t Login.'),
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 4)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: MaterialStateProperty.all(TextStyle(
                          color: Theme.of(context).colorScheme.primary))))
            ],
          )),
        ),
      ),
    );
  }
}
