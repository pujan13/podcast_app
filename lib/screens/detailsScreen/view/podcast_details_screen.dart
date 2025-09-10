import 'package:flutter/material.dart';
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
    if (_playingIndex == index && _player.playing) {
      await _player.pause();
    } else {
      await _player.setAsset(episode.audioUrl);
      await _player.play();
      setState(() {
        _playingIndex = index;
      });
    }
    setState(() {});
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
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
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
              final isPlaying = _playingIndex == index && _player.playing;

              return Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.01),
                padding: EdgeInsets.all(width * 0.03),
                decoration: BoxDecoration(
                  color: const Color(0xFF4E03F0),
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.045,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          SizedBox(height: height * 0.003),
                          Text(
                            episode.createdAt,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: width * 0.035,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          SizedBox(height: height * 0.003),
                          Text(
                            episode.description ?? "",
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
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                            size: width * 0.09,
                          ),
                          onPressed: () => _playEpisode(index),
                        ),
                        Text(
                          episode.duration,
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
              );
            }),
          ),
        ],
      ),
    );
  }
}
