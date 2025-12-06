part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {}

class AddNote extends NotesEvent {
  final Note note;
  final String? imagePath;
  const AddNote({required this.note, this.imagePath});
  @override
  List<Object> get props => [note];
}

class UpdateNote extends NotesEvent {
  final Note note;
  final String? imagePath;
  const UpdateNote({required this.note, this.imagePath});
  @override
  List<Object> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String id;
  const DeleteNote(this.id);
  @override
  List<Object> get props => [id];
}

class NotesLoadedEvent extends NotesEvent {
  final List<Note> notes;
  const NotesLoadedEvent(this.notes);
  @override
  List<Object> get props => [notes];
}

class NotesErrorEvent extends NotesEvent {
  final String message;
  const NotesErrorEvent(this.message);
  @override
  List<Object> get props => [message];
}


class SearchNotes extends NotesEvent {
  final String query;
  const SearchNotes(this.query);
}

enum NoteFilter { all, withPhoto, favorites, recent }
class ChangeFilter extends NotesEvent {
  final NoteFilter filter;
  const ChangeFilter(this.filter);
}

enum SortOption { dateDesc, dateAsc, titleAsc }
class SortNotes extends NotesEvent {
  final SortOption option;
  const SortNotes(this.option);
}

class ToggleFavorite extends NotesEvent {
  final Note note;
  const ToggleFavorite(this.note);
}

class ToggleSelectionMode extends NotesEvent {}
class ToggleSelectNote extends NotesEvent {
  final String noteId;
  const ToggleSelectNote(this.noteId);
}
class DeleteSelectedNotes extends NotesEvent {}