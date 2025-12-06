import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/note.dart';
import '../../../core/notes_repository.dart';
import 'dart:async';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository notesRepository;
  final String userId;

  StreamSubscription? _notesSubscription;

  NotesBloc({
    required this.notesRepository,
    required this.userId,
  }) : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<NotesLoadedEvent>(_onNotesLoaded);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<NotesErrorEvent>(_onError);
    on<SearchNotes>(_onSearchNotes);
    on<ChangeFilter>(_onChangeFilter);
    on<SortNotes>(_onSortNotes);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ToggleSelectionMode>(_onToggleSelectionMode);
    on<ToggleSelectNote>(_onToggleSelectNote);
    on<DeleteSelectedNotes>(_onDeleteSelectedNotes);
  }

  Future<void> _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading(notes: state.notes));
    _notesSubscription?.cancel();
    _notesSubscription = notesRepository.getNotesStream(userId).listen(
          (notes) => add(NotesLoadedEvent(notes)),
      onError: (error) => add(NotesErrorEvent(error.toString())),
    );
  }

  void _onNotesLoaded(NotesLoadedEvent event, Emitter<NotesState> emit) {
    if (state is NotesLoadSuccess) {
      final currState = state as NotesLoadSuccess;
      final visible = _filterAndSort(event.notes, currState.searchQuery, currState.filter, currState.sortOption);
      emit(NotesLoadSuccess(
        allNotes: event.notes,
        visibleNotes: visible,
        searchQuery: currState.searchQuery,
        filter: currState.filter,
        sortOption: currState.sortOption,
        isSelectionMode: currState.isSelectionMode,
        selectedNoteIds: currState.selectedNoteIds,
      ));
    } else {
      final visible = _filterAndSort(event.notes, '', NoteFilter.all, SortOption.dateDesc);
      emit(NotesLoadSuccess(allNotes: event.notes, visibleNotes: visible));
    }
  }


  void _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      String? imageUrl;
      if (event.imagePath != null) {
        imageUrl = await notesRepository.uploadImage(event.imagePath!);
      }
      final note = event.note.copyWith(imageUrl: imageUrl);
      await notesRepository.addNote(note);
    } catch (e) {
      add(NotesErrorEvent(e.toString()));
    }
  }

  void _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      String? imageUrl = event.note.imageUrl;
      if (event.imagePath != null) {
        imageUrl = await notesRepository.uploadImage(event.imagePath!);
      }
      final note = event.note.copyWith(imageUrl: imageUrl);
      await notesRepository.updateNote(note);
    } catch (e) {
      add(NotesErrorEvent(e.toString()));
    }
  }

  void _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await notesRepository.deleteNote(event.id);
    } catch (e) {
      add(NotesErrorEvent(e.toString()));
    }
  }


  void _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) {
    if (state is NotesLoadSuccess) {
      final curr = state as NotesLoadSuccess;
      final visible = _filterAndSort(curr.allNotes, event.query, curr.filter, curr.sortOption);
      emit(NotesLoadSuccess(
        allNotes: curr.allNotes,
        visibleNotes: visible,
        searchQuery: event.query,
        filter: curr.filter,
        sortOption: curr.sortOption,
        isSelectionMode: curr.isSelectionMode,
        selectedNoteIds: curr.selectedNoteIds,
      ));
    }
  }

  void _onChangeFilter(ChangeFilter event, Emitter<NotesState> emit) {
    if (state is NotesLoadSuccess) {
      final curr = state as NotesLoadSuccess;
      final visible = _filterAndSort(curr.allNotes, curr.searchQuery, event.filter, curr.sortOption);
      emit(NotesLoadSuccess(
        allNotes: curr.allNotes,
        visibleNotes: visible,
        searchQuery: curr.searchQuery,
        filter: event.filter,
        sortOption: curr.sortOption,
        isSelectionMode: curr.isSelectionMode,
        selectedNoteIds: curr.selectedNoteIds,
      ));
    }
  }

  void _onSortNotes(SortNotes event, Emitter<NotesState> emit) {
    if (state is NotesLoadSuccess) {
      final curr = state as NotesLoadSuccess;
      final visible = _filterAndSort(curr.allNotes, curr.searchQuery, curr.filter, event.option);
      emit(NotesLoadSuccess(
        allNotes: curr.allNotes,
        visibleNotes: visible,
        searchQuery: curr.searchQuery,
        filter: curr.filter,
        sortOption: event.option,
        isSelectionMode: curr.isSelectionMode,
        selectedNoteIds: curr.selectedNoteIds,
      ));
    }
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<NotesState> emit) async {
    try {
      final updated = event.note.copyWith(isFavorite: !event.note.isFavorite);
      await notesRepository.updateNote(updated);
    } catch (e) {
      add(NotesErrorEvent(e.toString()));
    }
  }

  void _onToggleSelectionMode(ToggleSelectionMode event, Emitter<NotesState> emit) {
    if (state is NotesLoadSuccess) {
      final curr = state as NotesLoadSuccess;
      emit(NotesLoadSuccess(
        allNotes: curr.allNotes,
        visibleNotes: curr.notes,
        searchQuery: curr.searchQuery,
        filter: curr.filter,
        sortOption: curr.sortOption,
        isSelectionMode: !curr.isSelectionMode,
        selectedNoteIds: const {},
      ));
    }
  }

  void _onToggleSelectNote(ToggleSelectNote event, Emitter<NotesState> emit) {
    if (state is NotesLoadSuccess) {
      final curr = state as NotesLoadSuccess;
      final newSelection = Set<String>.from(curr.selectedNoteIds);
      if (newSelection.contains(event.noteId)) {
        newSelection.remove(event.noteId);
      } else {
        newSelection.add(event.noteId);
      }

      emit(NotesLoadSuccess(
        allNotes: curr.allNotes,
        visibleNotes: curr.notes,
        searchQuery: curr.searchQuery,
        filter: curr.filter,
        sortOption: curr.sortOption,
        isSelectionMode: curr.isSelectionMode,
        selectedNoteIds: newSelection,
      ));
    }
  }

  void _onDeleteSelectedNotes(DeleteSelectedNotes event, Emitter<NotesState> emit) async {
    if (state is NotesLoadSuccess) {
      final curr = state as NotesLoadSuccess;
      for (var id in curr.selectedNoteIds) {
        await notesRepository.deleteNote(id);
      }
      add(ToggleSelectionMode());
    }
  }

  void _onError(NotesErrorEvent event, Emitter<NotesState> emit) {
    emit(NotesError(message: event.message, notes: state.notes));
  }

  List<Note> _filterAndSort(List<Note> all, String query, NoteFilter filter, SortOption sort) {
    var result = all;

    if (filter == NoteFilter.withPhoto) {
      result = result.where((n) => n.imageBase64 != null && n.imageBase64!.isNotEmpty).toList();
    } else if (filter == NoteFilter.favorites) {
      result = result.where((n) => n.isFavorite).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((n) => n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q)).toList();
    }

    result.sort((a, b) {
      switch (sort) {
        case SortOption.titleAsc: return a.title.compareTo(b.title);
        case SortOption.dateAsc: return a.date.compareTo(b.date);
        case SortOption.dateDesc: default: return b.date.compareTo(a.date);
      }
    });

    return result;
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }
}