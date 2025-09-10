import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../detailsScreen/model/episode_model.dart';

class PlayerScreen extends StatefulWidget {
  final Episode episode; // Assuming Episode is your data model
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const PlayerScreen({
    super.key,
    required this.episode,
    required this.audioPlayer,
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  State<PlayerScreen> createState() => _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Start playing the episode if not already playing
    if (!widget.isPlaying) {
      widget.onPlayPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF212159),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Episode Cover
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/podcast_cover.png', // Use the same cover or episode-specific image
                  height: width * 0.5,
                  width: width * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Episode Title
            Text(
              widget.episode.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Episode Description
            Text(
              widget.episode.description ?? "",
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 16,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Episode Duration
            Text(
              widget.episode.duration,
              style: TextStyle(
                color: Colors.white70,
                fontSize: width * 0.04,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 24),
            // Play/Pause Button
            Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isPlaying)
                  SizedBox(
                    width: width * 0.12,
                    height: width * 0.12,
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                      strokeWidth: 3,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    widget.isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: width * 0.12,
                  ),
                  onPressed: widget.onPlayPause,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}