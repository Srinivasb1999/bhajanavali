import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/song.dart';
import '../services/firestore_service.dart';
import '../widgets/paginated_dropdown.dart';

class SongManagementPage extends StatefulWidget {
  final Song? songToEdit; // If provided, we're editing an existing song

  const SongManagementPage({Key? key, this.songToEdit}) : super(key: key);

  @override
  State<SongManagementPage> createState() => _SongManagementPageState();
}

class _SongManagementPageState extends State<SongManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _raagaController = TextEditingController();
  final _authorController = TextEditingController();
  final _godController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isLoadingOptions = true;
  
  // Options for dropdowns
  List<String> _gods = [];
  List<String> _authors = [];
  List<String> _ragas = [];
  
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.songToEdit != null;
    
    // If editing, populate the form with existing data
    if (_isEditing && widget.songToEdit != null) {
      final song = widget.songToEdit!;
      _titleController.text = song.title;
      _lyricsController.text = song.lyrics ?? '';
      _raagaController.text = song.raaga?.join(', ') ?? '';
      _authorController.text = song.author ?? '';
      _godController.text = song.god ?? '';
    }
    
    _loadDropdownOptions();
  }

  Future<void> _loadDropdownOptions() async {
    setState(() {
      _isLoadingOptions = true;
    });
    
    try {
      final gods = await _firestoreService.getUniqueGods();
      final authors = await _firestoreService.getUniqueAuthors();
      final ragas = await _firestoreService.getUniqueRagas();
      
      setState(() {
        _gods = gods;
        _authors = authors;
        _ragas = ragas;
        _isLoadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOptions = false;
      });
      // Handle error silently for now
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _lyricsController.dispose();
    _raagaController.dispose();
    _authorController.dispose();
    _godController.dispose();
    super.dispose();
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final songData = {
        'title': _titleController.text.trim(),
        'lyrics': _lyricsController.text.trim(),
        'raaga': _raagaController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'author': _authorController.text.trim(),
        'god': _godController.text.trim(),
        'createdAt': _isEditing ? widget.songToEdit!.createdAt : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        // Update existing song
        await FirebaseFirestore.instance
            .collection('songs')
            .doc(widget.songToEdit!.id)
            .update(songData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.songUpdatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new song
        await FirebaseFirestore.instance
            .collection('songs')
            .add(songData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.songAddedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppLocalizations.of(context)!.editSong : AppLocalizations.of(context)!.addNewSong),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.titleLabel,
                        hintText: AppLocalizations.of(context)!.titleHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.titleLabel;
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // God Field - Paginated Dropdown
                    PaginatedDropdown(
                      labelText: AppLocalizations.of(context)!.godLabel,
                      hintText: AppLocalizations.of(context)!.godHint,
                      prefixIcon: Icons.auto_awesome,
                      options: _gods,
                      value: _godController.text.isEmpty ? null : _godController.text,
                      onChanged: (value) {
                        setState(() {
                          _godController.text = value ?? '';
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.godLabel;
                        }
                        return null;
                      },
                      isLoading: _isLoadingOptions,
                    ),
                    const SizedBox(height: 16),

                    // Author Field - Paginated Dropdown
                    PaginatedDropdown(
                      labelText: AppLocalizations.of(context)!.authorLabel,
                      hintText: AppLocalizations.of(context)!.authorHint,
                      prefixIcon: Icons.person,
                      options: _authors,
                      value: _authorController.text.isEmpty ? null : _authorController.text,
                      onChanged: (value) {
                        setState(() {
                          _authorController.text = value ?? '';
                        });
                      },
                      validator: null, // Make author optional
                      isLoading: _isLoadingOptions,
                    ),
                    const SizedBox(height: 16),

                    // Raga Field - Paginated Dropdown
                    PaginatedDropdown(
                      labelText: AppLocalizations.of(context)!.ragaLabel,
                      hintText: AppLocalizations.of(context)!.ragaHint,
                      prefixIcon: Icons.music_note,
                      options: _ragas,
                      value: _raagaController.text.isEmpty ? null : _raagaController.text,
                      onChanged: (value) {
                        setState(() {
                          _raagaController.text = value ?? '';
                        });
                      },
                      validator: null, // Make raga optional
                      isLoading: _isLoadingOptions,
                    ),
                    const SizedBox(height: 16),

                    // Lyrics Field
                    TextFormField(
                      controller: _lyricsController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.lyricsLabel,
                        hintText: AppLocalizations.of(context)!.lyricsHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.music_note),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.lyricsLabel;
                        }
                        return null;
                      },
                      maxLines: 10,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveSong,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditing ? AppLocalizations.of(context)!.updateSong : AppLocalizations.of(context)!.addSong,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
