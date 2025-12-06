import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../models/note.dart';
import '../../../core/image_service.dart';
import '../bloc/notes_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'side_menu.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final String userId;

  const NoteDetailScreen({
    super.key,
    this.note,
    required this.userId,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  String? _imageBase64;

  bool get _isCreating => widget.note == null;

  @override
  void initState() {
    super.initState();
    if (!_isCreating) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _imageBase64 = widget.note!.imageBase64;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageBase64 = await _imageService.pickImageAndConvertToBase64();
    if (imageBase64 != null && mounted) {
      setState(() {
        _imageBase64 = imageBase64;
      });
    }
  }

  Future<void> _takePhoto() async {
    final imageBase64 = await _imageService.takePhotoAndConvertToBase64();
    if (imageBase64 != null && mounted) {
      setState(() {
        _imageBase64 = imageBase64;
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final notesBloc = context.read<NotesBloc>();

      final note = Note(
        id: widget.note?.id ?? '',
        title: _titleController.text,
        content: _contentController.text,
        date: DateTime.now(),
        userId: widget.userId,
        imageBase64: _imageBase64,
      );

      if (_isCreating) {
        notesBloc.add(AddNote(note: note));
      } else {
        notesBloc.add(UpdateNote(note: note.copyWith(id: widget.note!.id)));
      }

      Navigator.of(context).pop();
    }
  }

  void _onDelete() {
    if (!_isCreating) {
      final notesBloc = context.read<NotesBloc>();
      notesBloc.add(DeleteNote(widget.note!.id));
      Navigator.of(context).pop();
    }
  }

  void _removeImage() {
    setState(() {
      _imageBase64 = null;
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Вибрати з галереї'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Зробити фото'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (_imageBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Видалити фото', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Скасувати'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          if (!isMobile) SideMenu(userId: widget.userId,),
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 700,
                ),
                margin: EdgeInsets.all(isMobile ? 0 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
                  boxShadow: isMobile ? [] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isCreating ? 'Нова нотатка' : 'Редагування нотатки',
                                style: TextStyle(
                                  fontSize: isMobile ? 20 : 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 24 : 32),

                          TextFormField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Назва нотатки',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.normal,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF7A00),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) =>
                            value == null || value.isEmpty ? 'Введіть заголовок' : null,
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _contentController,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Вміст нотатки...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.normal,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFF7A00),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              alignLabelWithHint: true,
                            ),
                            minLines: isMobile ? 8 : 10,
                            maxLines: 15,
                          ),

                          SizedBox(height: isMobile ? 16 : 24),

                          if (_imageBase64 != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Прикріплене зображення:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(
                                            _imageBase64!.contains(',')
                                                ? _imageBase64!.split(',').last
                                                : _imageBase64!,
                                          ),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.error, color: Colors.red),
                                            );
                                          },
                                        )
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red.withOpacity(0.8),
                                        radius: 16,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                          onPressed: _removeImage,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          OutlinedButton.icon(
                            onPressed: _showImageOptions,
                            icon: Icon(
                              _imageBase64 != null
                                  ? Icons.edit_outlined
                                  : Icons.add_photo_alternate_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            label: Text(
                              _imageBase64 != null
                                  ? 'Змінити фото'
                                  : 'Додати фото з галереї/камери',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),

                          SizedBox(height: isMobile ? 24 : 32),

                          if (isMobile)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _onSave,
                                  icon: const Icon(Icons.save, color: Colors.white, size: 20),
                                  label: const Text(
                                    'Зберегти',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF7A00),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Скасувати',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey.shade200,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Скасувати',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (!_isCreating)
                                  ElevatedButton.icon(
                                    onPressed: _onDelete,
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                                    label: const Text(
                                      'Видалити',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _onSave,
                                  icon: const Icon(Icons.save, color: Colors.white, size: 20),
                                  label: const Text(
                                    'Зберегти',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF7A00),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
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
            ),
          ),
        ],
      ),
    );
  }
}