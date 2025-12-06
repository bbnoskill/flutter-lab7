import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notebook_ui/core/auth_repository.dart';
import 'package:notebook_ui/core/monitoring_service.dart';
import 'package:notebook_ui/core/app_strings.dart';
import '../bloc/notes_bloc.dart';
import 'note_detail_screen.dart';

class SideMenu extends StatelessWidget {
  final String userId;

  const SideMenu({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (kIsWeb || constraints.maxWidth > 600) {
          return _SideMenuDesktop(userId: userId);
        } else {
          return _SideMenuMobile(userId: userId);
        }
      },
    );
  }
}

class _SideMenuDesktop extends StatelessWidget {
  final String userId;

  const _SideMenuDesktop({required this.userId});

  void _signOut(BuildContext context) async {
    try {
      await AuthRepository().signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = context.select((NotesBloc bloc) {
      if (bloc.state is NotesLoadSuccess) {
        return (bloc.state as NotesLoadSuccess).filter;
      }
      return NoteFilter.all;
    });

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Colors.deepOrange, size: 28),
              const SizedBox(width: 10),
              Text(AppStrings.appTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final notesBloc = BlocProvider.of<NotesBloc>(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => BlocProvider.value(value: notesBloc, child: NoteDetailScreen(note: null, userId: userId)),
                ));
              },
              label: const Text('Нова нотатка', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.add, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7A00), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            onChanged: (val) => context.read<NotesBloc>().add(SearchNotes(val)),
            decoration: InputDecoration(
              hintText: 'Пошук нотатки...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Мої нотатки', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: [
                _MenuItem(
                  icon: Icons.sticky_note_2, text: 'Усі нотатки',
                  isActive: currentFilter == NoteFilter.all,
                  onTap: () => context.read<NotesBloc>().add(const ChangeFilter(NoteFilter.all)),
                ),
                _MenuItem(
                  icon: Icons.photo, text: 'З фото',
                  isActive: currentFilter == NoteFilter.withPhoto,
                  onTap: () => context.read<NotesBloc>().add(const ChangeFilter(NoteFilter.withPhoto)),
                ),
                _MenuItem(
                  icon: Icons.star_border_rounded, text: 'Обрані',
                  isActive: currentFilter == NoteFilter.favorites,
                  onTap: () => context.read<NotesBloc>().add(const ChangeFilter(NoteFilter.favorites)),
                ),
                _MenuItem(
                  icon: Icons.timer, text: 'Нещодавні',
                  isActive: currentFilter == NoteFilter.recent,
                  onTap: () => context.read<NotesBloc>().add(const ChangeFilter(NoteFilter.recent)),
                ),
                const Divider(),
                _MenuItem(
                  icon: Icons.bug_report, text: 'Тест Crashlytics',
                  onTap: () => MonitoringService().testCrash(),
                ),
                _MenuItem(
                  icon: Icons.logout, text: 'Вихід',
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideMenuMobile extends StatelessWidget {
  final String userId;
  const _SideMenuMobile({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isActive;
  final VoidCallback? onTap;

  const _MenuItem({required this.icon, required this.text, this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.deepOrange : Colors.black87),
      title: Text(text, style: TextStyle(fontSize: 15, color: isActive ? Colors.deepOrange : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
      tileColor: isActive ? Colors.deepOrange.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}