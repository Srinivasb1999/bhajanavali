import 'package:flutter/material.dart';
import 'models/song.dart';
import 'services/firestore_service.dart';
import 'pages/song_detail_page.dart';
import 'dart:async';
import 'pages/song_management_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SongListingPage extends StatefulWidget {
  final bool isAdminMode;

  const SongListingPage({Key? key, this.isAdminMode = false}) : super(key: key);

  @override
  State<SongListingPage> createState() => _SongListingPageState();
}

class _SongListingPageState extends State<SongListingPage> {
  String? selectedGod;
  String? selectedRaga;
  String? selectedAlphabet;
  final FirestoreService _firestoreService = FirestoreService();
  List<String> gods = [];
  List<String> ragas = [];
  List<Song> allSongs = [];
  List<Song> filteredSongs = [];
  Map<String, List<Song>> songsByAlphabet = {};
  List<String> availableAlphabets = [];
  ScrollController _scrollController = ScrollController();
  bool _showAlphabetOverlay = false;
  bool _isAdminMode = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _isAdminMode = widget.isAdminMode;
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    final godsList = await _firestoreService.getUniqueGods();
    final ragasList = await _firestoreService.getUniqueRagas();
    
    setState(() {
      gods = godsList;
      ragas = ragasList;
    });
  }

  Stream<List<Song>> _getSongsStream() {
    if (selectedGod != null && selectedRaga != null) {
      return _firestoreService.getSongsByGodAndRaga(selectedGod!, selectedRaga!);
    } else if (selectedGod != null) {
      return _firestoreService.getSongsByGod(selectedGod!);
    } else if (selectedRaga != null) {
      return _firestoreService.getSongsByRaga(selectedRaga!);
    } else {
      return _firestoreService.getSongs();
    }
  }

  void _processSongs(List<Song> songs) {
    // Sort songs alphabetically by Kannada title
    songs.sort((a, b) => a.title.compareTo(b.title));
    
    // Group songs by first letter of Kannada title
    Map<String, List<Song>> grouped = {};
    for (Song song in songs) {
      if (song.title.isNotEmpty) {
        String firstLetter = song.title[0].toUpperCase();
        if (!grouped.containsKey(firstLetter)) {
          grouped[firstLetter] = [];
        }
        grouped[firstLetter]!.add(song);
      }
    }
    
    // Defer the state update until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          allSongs = songs;
          songsByAlphabet = grouped;
          availableAlphabets = grouped.keys.toList()..sort();
          // Apply current filters to the new songs
          if (selectedAlphabet != null) {
            filteredSongs = grouped[selectedAlphabet!] ?? [];
          } else {
            filteredSongs = songs;
          }
        });
      }
    });
  }

  void _applyFilters() {
    List<Song> filtered = List.from(allSongs);
    
    // Apply alphabet filter
    if (selectedAlphabet != null) {
      filtered = songsByAlphabet[selectedAlphabet!] ?? [];
    }
    
    // Don't call setState here to avoid glitchy rerenders
    filteredSongs = filtered;
  }

  void _scrollToAlphabet(String alphabet) {
    setState(() {
      selectedAlphabet = selectedAlphabet == alphabet ? null : alphabet;
      _showAlphabetOverlay = true;
    });
    _applyFilters();
    
    // Hide overlay after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAlphabetOverlay = false;
        });
      }
    });
  }

  void _onAlphabetScroll(double position) {
    if (availableAlphabets.isEmpty) return;
    
    // Cancel any existing timer
    _debounceTimer?.cancel();
    
    // Set a new timer to debounce the scroll
    _debounceTimer = Timer(Duration(milliseconds: 100), () {
      _performAlphabetScroll(position);
    });
  }

  void _performAlphabetScroll(double position) {
    if (availableAlphabets.isEmpty) return;
    
    // Calculate which alphabet should be selected based on scroll position
    // Account for the top margin and adjust for the scroll bar height
    final topMargin = 100.0; // Account for app bar and filters
    final adjustedPosition = position - topMargin;
    
    if (adjustedPosition < 0) return;
    
    // Calculate the height of the scroll bar area
    final scrollBarHeight = MediaQuery.of(context).size.height - topMargin - 40; // 40 for bottom margin
    final itemHeight = scrollBarHeight / availableAlphabets.length;
    
    // Calculate which item we're hovering over with better precision
    final index = (adjustedPosition / itemHeight).floor().clamp(0, availableAlphabets.length - 1);
    
    if (index < availableAlphabets.length) {
      final alphabet = availableAlphabets[index];
      if (selectedAlphabet != alphabet) {
        setState(() {
          selectedAlphabet = alphabet;
          _showAlphabetOverlay = true;
        });
        _applyFilters();
        
        // Hide overlay after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showAlphabetOverlay = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_isAdminMode)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongManagementPage(),
                  ),
                );
              },
              tooltip: AppLocalizations.of(context)!.addNewSong,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.god,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedGod,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppLocalizations.of(context)!.allGods),
                          ),
                          ...gods.map((god) => DropdownMenuItem(
                            value: god,
                            child: Text(god),
                          )).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGod = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.raga,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: selectedRaga,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(AppLocalizations.of(context)!.allRagas),
                          ),
                          ...ragas.map((raga) => DropdownMenuItem(
                            value: raga,
                            child: Text(raga),
                          )).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRaga = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Songs List
              Expanded(
                child: StreamBuilder<List<Song>>(
                  stream: _getSongsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.connectionError,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.connectionErrorDetails,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // This will trigger a rebuild and retry
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.retry),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final songs = snapshot.data ?? [];
                    
                    // Process songs for alphabet grouping
                    if (songs.isNotEmpty && allSongs.isEmpty) {
                      _processSongs(songs);
                    }

                    // Get the songs to display (either filtered or all)
                    List<Song> displaySongs;
                    if (selectedAlphabet != null) {
                      displaySongs = filteredSongs;
                    } else {
                      // If no alphabet selected, show all songs sorted alphabetically
                      displaySongs = List.from(songs)..sort((a, b) => a.title.compareTo(b.title));
                    }

                    if (displaySongs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noSongsFound,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (selectedGod != null || selectedRaga != null || selectedAlphabet != null)
                              Text(
                                AppLocalizations.of(context)!.tryAdjustFilters,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16),
                      itemCount: displaySongs.length,
                      itemBuilder: (context, index) {
                        final song = displaySongs[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple[100],
                              child: Icon(
                                Icons.music_note,
                                color: Colors.deepPurple,
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (song.god != null) ...[
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.auto_awesome, size: 16, color: Colors.orange[600]),
                                      SizedBox(width: 4),
                                      Text(
                                        song.god!,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                                if (song.author != null) ...[
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 16, color: Colors.purple[600]),
                                      SizedBox(width: 4),
                                      Text(
                                        song.author!,
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            trailing: Icon(
                              Icons.play_circle_outline,
                              color: Colors.deepPurple,
                              size: 32,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SongDetailPage(
                                    song: song,
                                    isAdminMode: _isAdminMode,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Alphabet Scroll Bar (Right Side)
          if (availableAlphabets.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 40,
                margin: EdgeInsets.only(top: 100, bottom: 20), // Account for app bar and filters
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(details.globalPosition);
                    _onAlphabetScroll(localPosition.dy);
                  },
                  onVerticalDragStart: (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(details.globalPosition);
                    _onAlphabetScroll(localPosition.dy);
                  },
                  onTapDown: (details) {
                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(details.globalPosition);
                    _onAlphabetScroll(localPosition.dy);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: availableAlphabets.asMap().entries.map((entry) {
                        final index = entry.key;
                        final alphabet = entry.value;
                        final isSelected = selectedAlphabet == alphabet;
                        
                        return GestureDetector(
                          onTap: () => _scrollToAlphabet(alphabet),
                          child: Container(
                            width: 40,
                            height: 24,
                            child: Center(
                              child: Text(
                                alphabet,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.deepPurple : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          
          // Alphabet Overlay
          if (_showAlphabetOverlay && selectedAlphabet != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    selectedAlphabet!,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          
          // Clear Alphabet Selection Button
          if (selectedAlphabet != null)
            Positioned(
              top: 120,
              right: 50,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAlphabet = null;
                    _showAlphabetOverlay = false;
                  });
                  _applyFilters();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

