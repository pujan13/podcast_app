import 'package:flutter/material.dart';
import '../../playerScreen/view/player_screen.dart';
import '../data/episode_list.dart'; // episode objects: title, description, date, duration, audioUrl
import 'package:just_audio/just_audio.dart';

class PodcastDetailsScreen extends StatefulWidget {
  const PodcastDetailsScreen({super.key});

  @override
  State<PodcastDetailsScreen> createState() => _PodcastDetailsScreenState();
}

class _PodcastDetailsScreenState extends State<PodcastDetailsScreen> {
  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _playEpisode(int index) async {
    final episode = episodes[index];
    try {
      if (_playingIndex == index && _player.playing) {
        await _player.pause();
        setState(() {
          _playingIndex = null; // Reset when paused
        });
      } else {
        if (episode.audioUrl == null || episode.audioUrl!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid audio URL')),
          );
          return;
        }
        await _player.setAsset(episode.audioUrl!);
        await _player.play();
        setState(() {
          _playingIndex = index;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
      setState(() {
        _playingIndex = null; // Reset on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery for responsive sizes
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF212159),
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: const Color(0xFF212159),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          Image.asset(
            "assets/images/icon_image.png",
            width: width * 0.2,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(width * 0.04),
        children: [
          // Podcast Cover
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.04),
              child: Image.asset(
                'assets/images/podcast_cover.png',
                height: height * 0.23,
                width: height * 0.23,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.025),
          // Podcast title & author
          Text(
            "The Blockchain Experience",
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.054,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: height * 0.005),
          Text(
            "Media3 Labs LLC",
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            "Welcome to The Blockchain Experience, a podcast hosted by meta-david, "
                "where we dive deep into the world of blockchain technology including, web3, NFTs, and decentralized systems...",
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.035,
              fontWeight: FontWeight.w400,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: height * 0.025),
          Text(
            "Wed, 11 Jan 2023  9:00 PM",
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.035,
              fontWeight: FontWeight.w400,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: height * 0.04),
          Text(
            "Available episodes",
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.047,
              fontWeight: FontWeight.w700,
              fontFamily: 'Outfit',
            ),
          ),
          SizedBox(height: height * 0.015),
          // Episode List
          Column(
            children: List.generate(episodes.length, (index) {
              final episode = episodes[index];
              final isSelected = _playingIndex == index;
              final isPlaying = isSelected && _player.playing;

              return GestureDetector(
                onTap: () {
                  // Navigate to PlayerScreen and pass episode data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(
                        episode: episode,
                        audioPlayer: _player,
                        isPlaying: isPlaying,
                        onPlayPause: () => _playEpisode(index),
                      ),
                    ),
                  ).then((_) {
                    // Update UI when returning from PlayerScreen
                    setState(() {
                      _playingIndex = _player.playing ? index : null;
                    });
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: height * 0.01),
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4E03F0),
                    borderRadius: BorderRadius.circular(width * 0.03),
                    border: isSelected
                        ? Border.all(color: Colors.deepOrangeAccent, width: 2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isSelected)
                                  Padding(
                                    padding: EdgeInsets.only(right: width * 0.015),
                                    child: Text(
                                      "🧠",
                                      style: TextStyle(fontSize: width * 0.045),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    episode.title ?? 'Untitled Episode',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.045,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.003),
                            Text(
                              episode.createdAt ?? 'Unknown date',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: width * 0.035,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            SizedBox(height: height * 0.003),
                            Text(
                              episode.description ?? 'No description available',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: width * 0.03,
                                fontFamily: 'Outfit',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isPlaying)
                                SizedBox(
                                  width: width * 0.09,
                                  height: width * 0.09,
                                  child: CircularProgressIndicator(
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                        Colors.purpleAccent),
                                    strokeWidth: 3,
                                  ),
                                ),
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                                  color: Colors.white,
                                  size: width * 0.09,
                                ),
                                onPressed: () => _playEpisode(index),
                              ),
                            ],
                          ),
                          Text(
                            episode.duration ?? '0:00',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: width * 0.03,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}