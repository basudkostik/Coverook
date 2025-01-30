import 'package:flutter/material.dart';
import 'package:kavruk/constants/routers.dart';
import 'package:kavruk/explore_page.dart';
import 'package:kavruk/views/book_card_screen.dart';
import 'package:kavruk/views/profile_view.dart';
import 'package:kavruk/user/auth_service.dart';
import 'package:kavruk/views/coverookhomepage.dart';
import 'package:kavruk/views/login_view.dart';
import 'package:kavruk/views/register_view.dart';
import 'package:kavruk/user/user_data.dart';
import 'package:kavruk/views/verify_email_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coverook',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.brown[900], fontSize: 16),
          bodyMedium: TextStyle(color: Colors.brown[800], fontSize: 14),
          titleLarge: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: 'Black Mango'),
        ),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        additionalInfoRoute: (context) => const AdditionalInfoView(),
        profileRoute: (context) => ProfileScreen(
              userId: AuthService.firebase().currentUser!.id,
            ),
        homepageRoute: (context) => CoverookHomePage(),
        exploreRoute: (context) => ExplorePage(),
      },
      home: testing(),
    );
  }
}

class testing extends StatelessWidget {
  const testing({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return CoverookHomePage();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
