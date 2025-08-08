import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

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
            content: Text('Song updated successfully!'),
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
            content: Text('Song added successfully!'),
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
        title: Text(_isEditing ? 'Edit Song' : 'Add New Song'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Field
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        hintText: 'Enter song title in Kannada',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),

                    // God Field
                    TextFormField(
                      controller: _godController,
                      decoration: InputDecoration(
                        labelText: 'God *',
                        hintText: 'Enter the god this song is dedicated to',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.auto_awesome),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'God is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Author Field
                    TextFormField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        labelText: 'Author *',
                        hintText: 'Enter the author/composer name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Author is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Raga Field
                    TextFormField(
                      controller: _raagaController,
                      decoration: InputDecoration(
                        labelText: 'Raga *',
                        hintText: 'Enter raga(s) separated by commas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.music_note),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Raga is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Lyrics Field
                    TextFormField(
                      controller: _lyricsController,
                      decoration: InputDecoration(
                        labelText: 'Lyrics *',
                        hintText: 'Enter the complete lyrics in Kannada',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.music_note),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lyrics are required';
                        }
                        return null;
                      },
                      maxLines: 10,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                    SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveSong,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Update Song' : 'Add Song',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
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
