// lib/screens/podcast_details_screen.dart
import 'package:flutter/material.dart';
import '../data/episode_list.dart'; // Make sure episode objects have title, description, date, duration, audioUrl
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
    return Scaffold(
      backgroundColor: const Color(0xFF212159),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new),color: Colors.white,),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Image.asset("assets/images/icon_image.png"),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Podcast Cover
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/podcast_cover.png',
                height: 180,
                width: 180,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          // Podcast title & author
          const Text(
            "The Blockchain Experience",
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Media3 Labs LLC",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const Text(
            "Welcome to The Blockchain Experience, a podcast hosted by meta-david, "
                "where we dive deep into the world of blockchain technology including, web3, NFTs, and decentralized systems...",
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 24),
          const Text(
            "Available episodes",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Episode List
          Column(
            children: List.generate(episodes.length, (index) {
              final episode = episodes[index];
              final isPlaying = _playingIndex == index && _player.playing;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4E03F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            episode.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            episode.title ?? "",
                            style:
                            const TextStyle(color: Colors.white60, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () => _playEpisode(index),
                        ),
                        Text(
                          episode.duration,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
