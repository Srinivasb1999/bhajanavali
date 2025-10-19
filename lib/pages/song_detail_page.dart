import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/song.dart';
import 'song_management_page.dart';

class SongDetailPage extends StatelessWidget {
  final Song song;
  final bool isAdminMode;

  const SongDetailPage({Key? key, required this.song, this.isAdminMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          song.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isAdminMode)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongManagementPage(songToEdit: song),
                  ),
                );
              },
              tooltip: AppLocalizations.of(context)!.editSong,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Card
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 20),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[800],
                  ),
                ),
              ),
            ),
            
            // Lyrics Section (Now First)
            if (song.lyrics != null && song.lyrics!.isNotEmpty) ...[
              Card(
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: SelectableText(
                    song.lyrics!,
                    style: _getTextStyle(song.lyrics!),
                    textDirection: _getTextDirection(song.lyrics!),
                  ),
                ),
              ),
            ] else ...[
              // No lyrics available
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.lyricsNotAvailableTitle,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.lyricsNotAvailableBody,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Song Details Section (Now at Bottom)
            if (song.god != null || song.author != null || song.raaga != null || 
                song.audioUrl != null || song.imageUrl != null || song.createdAt != null) ...[
              SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.songDetails,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Tags section with Wrap
                      if (song.god != null || song.author != null || song.raaga != null) ...[
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (song.god != null)
                              _buildInfoChip(
                                icon: Icons.auto_awesome,
                                label: song.god!,
                                color: Colors.orange[100]!,
                                textColor: Colors.orange[800]!,
                              ),
                            if (song.author != null)
                              _buildInfoChip(
                                icon: Icons.person,
                                label: song.author!,
                                color: Colors.purple[100]!,
                                textColor: Colors.purple[800]!,
                              ),
                            if (song.firstRaga != null)
                              _buildInfoChip(
                                icon: Icons.music_note,
                                label: song.firstRaga!,
                                color: Colors.green[100]!,
                                textColor: Colors.green[800]!,
                              ),
                          ],
                        ),
                        
                        // Multiple ragas indicator
                        if (song.raaga != null && song.raaga!.length > 1) ...[
                          SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.allRagasLine(song.raaga!.join(', ')),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 16),
                      ],
                      
                      // Additional details
                      if (song.audioUrl != null) ...[
                        _buildDetailRow(
                          icon: Icons.audiotrack,
                          label: AppLocalizations.of(context)!.audioAvailable,
                          value: AppLocalizations.of(context)!.yes,
                          color: Colors.green[600]!,
                        ),
                        SizedBox(height: 12),
                      ],
                      
                      if (song.imageUrl != null) ...[
                        _buildDetailRow(
                          icon: Icons.image,
                          label: AppLocalizations.of(context)!.imageAvailable,
                          value: AppLocalizations.of(context)!.yes,
                          color: Colors.blue[600]!,
                        ),
                        SizedBox(height: 12),
                      ],
                      
                      if (song.createdAt != null) ...[
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: AppLocalizations.of(context)!.added,
                          value: _formatDate(song.createdAt!),
                          color: Colors.orange[600]!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Get appropriate text style based on language
  TextStyle _getTextStyle(String text) {
    // Check for Kannada characters (Unicode range: 0C80-0CFF)
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(text)) {
      return GoogleFonts.notoSansKannada(
        fontSize: 16,
        height: 1.6,
      );
    }
    
    // Check for Hindi/Devanagari characters (Unicode range: 0900-097F)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) {
      return GoogleFonts.notoSansDevanagari(
        fontSize: 16,
        height: 1.6,
      );
    }
    
    // Default to system font for English
    return GoogleFonts.roboto(
      fontSize: 16,
      height: 1.6,
    );
  }

  // Detect text direction
  TextDirection _getTextDirection(String text) {
    // Check for RTL languages (Arabic, Hebrew, etc.)
    if (RegExp(r'[\u0590-\u05FF\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text)) {
      return TextDirection.rtl;
    }
    
    // Default to LTR for most languages including Kannada, Hindi, English
    return TextDirection.ltr;
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
