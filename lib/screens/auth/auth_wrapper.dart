import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/auth_repository.dart';
import '../home/bloc/notes_bloc.dart';
import '../home/home_screen.dart';
import 'auth_screen.dart';
import '../../core/notes_repository.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final userId = snapshot.data!.uid;
          final notesRepository = FirestoreNotesRepository();

          return BlocProvider(
            create: (context) => NotesBloc(
              notesRepository: notesRepository,
              userId: userId,
            )..add(LoadNotes()),
            child: HomeScreen(userId: userId),
          );
        }

        return const AuthScreen();
      },
    );
  }
}