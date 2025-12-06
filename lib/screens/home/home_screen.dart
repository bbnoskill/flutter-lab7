import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/notes_bloc.dart';
import 'widgets/center_menu.dart';
import 'widgets/side_menu.dart';

class HomeScreen extends StatelessWidget {
  final String userId;
  const HomeScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 600;

        final Widget centerMenuWithBloc = BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {

            if (state is NotesLoading && state.notes.isEmpty) {
              return isDesktop
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                height: MediaQuery.of(context).size.height * 0.5,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }

            if (state is NotesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Не вдалося завантажити нотатки.\n${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            }

            return CenterMenu(notes: state.notes, userId: userId,);
          },
        );

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                SideMenu(userId: userId),
                Expanded(
                  child: centerMenuWithBloc,
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notebook'),
              backgroundColor: const Color(0xFFF8F8F8),
            ),
            drawer: Drawer(
              child: SideMenu(userId: userId),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: centerMenuWithBloc,
            ),
          );
        }
      },
    );
  }
}