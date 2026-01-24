import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'languageSelection.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _fullNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE6ED), Color(0xFFfffdfd)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BIBI Logo
                  Image.asset(
                    'assets/images/Bibi_Logo_Vector 1.png',
                    height: 60,
                    width: 60,
                  ),
                  SizedBox(height: 4),
                  // Welcome Title
                  Text(
                    'Welcome to BIBI',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Let\'s get to know you better',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Illustration
                  Image.asset(
                    'assets/images/amico.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 28),
                  // Full Name Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your fullname',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // City or Region Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City or Region',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Karachi, Lahore, Islamabad',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Image.asset(
                              'assets/images/location_icon.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Age Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8B6F47),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter your age',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Image.asset(
                              'assets/images/calender.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Get Started Button
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Welcome ${state.fullName}!'),
                            backgroundColor: Color(0xFFE85B99),
                          ),
                        );
                        // Navigate to language selection
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LanguageSelectionPage(),
                          ),
                        );
                      } else if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          SubmitUserDataEvent(
                                            fullName: _fullNameController.text,
                                            city: _cityController.text,
                                            age: _ageController.text,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE85B99),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Security Note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security,
                        size: 16,
                        color: Color(0xFFFFA500),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Your information is secure and private',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}