import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/note.dart';
import 'note_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';

class CenterMenu extends StatelessWidget {
  final List<Note> notes;
  final String userId;

  const CenterMenu({
    super.key,
    required this.notes,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _CenterMenuDesktop(
            notes: notes,
            userId: userId,
          );
        } else {
          return _CenterMenuMobile(
            notes: notes,
            userId: userId,
          );
        }
      },
    );
  }
}

class _CenterMenuDesktop extends StatelessWidget {
  final List<Note> notes;
  final String userId;

  const _CenterMenuDesktop({
    required this.notes,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = notes.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          _TopBar(noteCount: notes.length),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isEmpty
                      ? _EmptyState(userId: userId)
                      : _NotesGrid(notes: notes, userId: userId),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SortOption({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(title, style: TextStyle(color: Colors.grey.shade800)),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int noteCount;
  const _TopBar({required this.noteCount});

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = context.select((NotesBloc bloc) {
      if (bloc.state is NotesLoadSuccess) return (bloc.state as NotesLoadSuccess).isSelectionMode;
      return false;
    });

    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Усі нотатки',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$noteCount нотаток',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showSortDialog(context),
              icon: const Icon(Icons.sort),
              tooltip: 'Сортування',
            ),
            IconButton(
              onPressed: () => context.read<NotesBloc>().add(ToggleSelectionMode()),
              icon: Icon(
                isSelectionMode ? Icons.check_circle : Icons.check_circle_outline,
                color: isSelectionMode ? Colors.deepOrange : null,
              ),
              tooltip: 'Вибір',
            ),
            IconButton(
              onPressed: () => _showExportDialog(context),
              icon: const Icon(Icons.download),
              tooltip: 'Експорт',
            ),
            IconButton(
              onPressed: isSelectionMode
                  ? () => _showDeleteConfirmation(context, true)
                  : null,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isSelectionMode ? Colors.red : Colors.grey,
              ),
              tooltip: 'Видалення',
            ),
          ],
        ),
      ],
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Сортувати за'),
        children: [
          SimpleDialogOption(
            child: const Text('Датою (Нові)'),
            onPressed: () {
              context.read<NotesBloc>().add(const SortNotes(SortOption.dateDesc));
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            child: const Text('Датою (Старі)'),
            onPressed: () {
              context.read<NotesBloc>().add(const SortNotes(SortOption.dateAsc));
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            child: const Text('Назвою (А-Я)'),
            onPressed: () {
              context.read<NotesBloc>().add(const SortNotes(SortOption.titleAsc));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.download, color: Colors.deepOrange.shade400),
              const SizedBox(width: 10),
              const Text('Експорт нотаток'),
            ],
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Експортується 1 нотаток',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                _ExportOption(
                  icon: Icons.picture_as_pdf,
                  title: 'PDF документ',
                  subtitle: 'Найкращий для друку та збереження',
                  onTap: () => Navigator.pop(context),
                ),
                _ExportOption(
                  icon: Icons.text_snippet,
                  title: 'ТХТ файл',
                  subtitle: 'Простий текстовий формат',
                  onTap: () => Navigator.pop(context),
                ),
                _ExportOption(
                  icon: Icons.image,
                  title: 'PNG зображення',
                  subtitle: 'Експорт як картинка',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Скасувати'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, bool multiple) {
    final isSelectionMode = context.select((NotesBloc bloc) {
      if (bloc.state is NotesLoadSuccess) return (bloc.state as NotesLoadSuccess).isSelectionMode;
      return false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 36),
          title: Text(multiple ? 'Видалити обрані нотатки?' : 'Видалити нотатку?'),
          content: Text(
            multiple
                ? 'Ви впевнені, що хочете видалити обрані нотатки? Відновити буде неможливо.'
                : 'Ви впевнені, що хочете видалити цю нотатку? Відновити буде неможливо.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            TextButton(
              child: const Text('Скасувати', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Видалити'),
              onPressed: () {
                if (isSelectionMode) {
                  context.read<NotesBloc>().add(DeleteSelectedNotes());
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey[50],
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrange),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String userId;

  const _EmptyState({required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A00),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 36),
              onPressed: () {
                final notesBloc = BlocProvider.of<NotesBloc>(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: notesBloc,
                      child: NoteDetailScreen(
                        note: null,
                        userId: userId,
                      ),
                    ),
                  ),
                );
              },
              tooltip: 'Створити нотатку',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Почніть створювати нотатку',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ) ??
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Натисніть кнопку "+" щоб створити першу нотатку',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey) ??
                const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotesGrid extends StatelessWidget {
  final List<Note> notes;
  final String userId;

  const _NotesGrid({
    required this.notes,
    required this.userId,
  });

  int _columnsForWidth(double width) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnsForWidth(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: notes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) => _NoteCard(
            note: notes[index],
            userId: userId,
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final String userId;

  const _NoteCard({required this.note, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = context.select((NotesBloc b) =>
    (b.state is NotesLoadSuccess) ? (b.state as NotesLoadSuccess).isSelectionMode : false);
    final isSelected = context.select((NotesBloc b) =>
    (b.state is NotesLoadSuccess) ? (b.state as NotesLoadSuccess).selectedNoteIds.contains(note.id) : false);

    return Material(
      color: isSelected ? Colors.orange.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: Colors.deepOrange, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            context.read<NotesBloc>().add(ToggleSelectNote(note.id));
          } else {
            final notesBloc = BlocProvider.of<NotesBloc>(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: notesBloc,
                  child: NoteDetailScreen(
                    note: note,
                    userId: userId,
                  ),
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Відображення зображення, якщо воно є
                  if (note.imageBase64 != null && note.imageBase64!.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(note.imageBase64!.split(',').last),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isSelectionMode && note.imageBase64 != null)
                        const Icon(Icons.photo, size: 16, color: Colors.blue),
                      if (!isSelectionMode)
                        GestureDetector(
                          onTap: () => context.read<NotesBloc>().add(ToggleFavorite(note)),
                          child: Icon(
                            note.isFavorite ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note.content,
                      maxLines: note.imageBase64 != null ? 4 : 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      note.date != null
                          ? '${note.date!.year}-${note.date!.month.toString().padLeft(2, '0')}-${note.date!.day.toString().padLeft(2, '0')}'
                          : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelectionMode)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: Colors.deepOrange,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CenterMenuMobile extends StatelessWidget {
  final List<Note> notes;
  final String userId;

  const _CenterMenuMobile({
    required this.notes,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = notes.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Усі нотатки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              BlocBuilder<NotesBloc, NotesState>(
                builder: (context, state) {
                  final isSelectionMode = state is NotesLoadSuccess ? state.isSelectionMode : false;
                  return Row(
                    children: [
                      _SmallIconButton(
                        icon: Icons.sort,
                        color: Colors.grey,
                        onPressed: () {
                          _showSortDialog(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      _SmallIconButton(
                        icon: isSelectionMode ? Icons.check_circle : Icons.check_circle_outline,
                        color: isSelectionMode ? Colors.deepOrange : Colors.grey,
                        onPressed: () {
                          context.read<NotesBloc>().add(ToggleSelectionMode());
                        },
                      ),
                      const SizedBox(width: 4),
                      _SmallIconButton(
                        icon: Icons.download,
                        color: Colors.grey,
                        onPressed: () {
                          _TopBar(noteCount: notes.length)._showExportDialog(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      _SmallIconButton(
                        icon: Icons.delete_outline_rounded,
                        color: isSelectionMode ? Colors.red : Colors.grey,
                        onPressed: isSelectionMode
                            ? () => _TopBar(noteCount: notes.length)._showDeleteConfirmation(context, true)
                            : null,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: _EmptyState(userId: userId),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteItem(
                  note: note,
                  userId: userId,
                );
              },
            ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Сортувати за'),
        children: [
          SimpleDialogOption(
            child: const Text('Датою (Нові)'),
            onPressed: () {
              context.read<NotesBloc>().add(const SortNotes(SortOption.dateDesc));
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            child: const Text('Датою (Старі)'),
            onPressed: () {
              context.read<NotesBloc>().add(const SortNotes(SortOption.dateAsc));
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            child: const Text('Назвою (А-Я)'),
            onPressed: () {
              context.read<NotesBloc>().add(const SortNotes(SortOption.titleAsc));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SmallIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onPressed,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final Note note;
  final String userId;

  const _NoteItem({required this.note, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isSelectionMode = context.select((NotesBloc b) =>
    (b.state is NotesLoadSuccess) ? (b.state as NotesLoadSuccess).isSelectionMode : false);
    final isSelected = context.select((NotesBloc b) =>
    (b.state is NotesLoadSuccess) ? (b.state as NotesLoadSuccess).selectedNoteIds.contains(note.id) : false);

    return InkWell(
      onTap: () {
        if (isSelectionMode) {
          context.read<NotesBloc>().add(ToggleSelectNote(note.id));
        } else {
          final notesBloc = BlocProvider.of<NotesBloc>(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: notesBloc,
                child: NoteDetailScreen(
                  note: note,
                  userId: userId,
                ),
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade50 : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.deepOrange, width: 2) : null,
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.content,
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.date != null
                            ? note.date.toString().substring(0, 16)
                            : '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (!isSelectionMode)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          note.isFavorite ? Icons.star : Icons.star_border_rounded,
                          color: Colors.orange,
                        ),
                        onPressed: () => context.read<NotesBloc>().add(ToggleFavorite(note)),
                      ),
                    ],
                  ),
              ],
            ),
            if (isSelectionMode)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: Colors.deepOrange,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}