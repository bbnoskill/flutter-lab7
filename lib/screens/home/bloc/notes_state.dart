part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {
  final List<Note> notes;

  NotesState({this.notes = const []});

  @override
  List<Object> get props => [notes];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {
  NotesLoading({required super.notes});
}

class NotesLoaded extends NotesState {
  NotesLoaded({required super.notes});
}

class NotesError extends NotesState {
  final String message;
  NotesError({required this.message, required super.notes});
  @override
  List<Object> get props => [message, notes];
}

class NotesLoadSuccess extends NotesState {
  final List<Note> allNotes;
  final String searchQuery;
  final NoteFilter filter;
  final SortOption sortOption;
  final bool isSelectionMode;
  final Set<String> selectedNoteIds;

  NotesLoadSuccess({
    required this.allNotes,
    required List<Note> visibleNotes,
    this.searchQuery = '',
    this.filter = NoteFilter.all,
    this.sortOption = SortOption.dateDesc,
    this.isSelectionMode = false,
    this.selectedNoteIds = const {},
  }) : super(notes: visibleNotes);

  @override
  List<Object> get props => [
    notes,
    allNotes,
    searchQuery,
    filter,
    sortOption,
    isSelectionMode,
    selectedNoteIds
  ];
}