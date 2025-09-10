import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../playerScreen/view/player_screen.dart';
import '../data/episode_list.dart'; // episode objects: title, description, date, duration, audioUrl
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;

class GradientBorderPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GradientProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  GradientProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          );

    // Draw background circle (optional, for contrast)
    final backgroundPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc starting from bottom (π/2 radians)
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2, // Start from bottom
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PodcastDetailsScreen extends StatefulWidget {
  const PodcastDetailsScreen({super.key});

  @override
  State<PodcastDetailsScreen> createState() => _PodcastDetailsScreenState();
}

class _PodcastDetailsScreenState extends State<PodcastDetailsScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Gradient rotation speed
    );
    // Listen to audio position and duration for progress indicator
    _player.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentDuration = position;
        });
      }
    });
    _player.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });
    // Control gradient animation based on playback state
    _player.playingStream.listen((playing) {
      if (playing && _playingIndex != null) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _player.dispose();
    super.dispose();
  }

  void _playEpisode(int index) async {
    final episode = episodes[index];
    // Update state immediately to reflect the action
    setState(() {
      if (_playingIndex == index && _player.playing) {
        _playingIndex = null; // Reset for pause
      } else {
        _playingIndex = index; // Set for play
      }
    });

    try {
      if (_playingIndex == null) {
        await _player.pause();
      } else {
        if (episode.audioUrl == null || episode.audioUrl!.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invalid audio URL')));
          setState(() {
            _playingIndex = null; // Reset on invalid URL
          });
          return;
        }
        print('Playing audio: ${episode.audioUrl}'); // Debug audio URL
        await _player.setAsset(episode.audioUrl!);
        await _player.play();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
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
          onPressed: () {
            // Disabled as this is the first screen
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        actions: [
          Image.asset(
            "assets/images/icon_image.png",
            width: width * 0.2,
            errorBuilder:
                (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 40,
                  color: Colors.white70,
                ),
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
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
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
              const double borderWidth = 4.0;

              return GestureDetector(
                onTap: () {
                  // Start playing immediately
                  _playEpisode(index);
                  // Navigate to PlayerScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PlayerScreen(
                            episode: episode,
                            audioPlayer: _player,
                            isPlaying: isPlaying,
                            onPlayPause: () => _playEpisode(index),
                            onNext: () {},
                            onPrevious: () {},
                            hasNext: true,
                            hasPrevious: true,
                          ),
                    ),
                  ).then((_) {
                    // Update UI when returning from PlayerScreen
                    setState(() {
                      _playingIndex = _player.playing ? index : null;
                    });
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  margin: EdgeInsets.symmetric(vertical: height * 0.01),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                  child:
                      isSelected
                          ? AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: GradientBorderPainter(
                                  strokeWidth: borderWidth,
                                  radius: width * 0.03,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFC19E8E),
                                      Color(0xFF6748FF),
                                    ],
                                    transform: GradientRotation(math.pi * 2),
                                  ),
                                ),
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  width * 0.03,
                                ),
                              ),
                              padding: EdgeInsets.all(width * 0.03),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              episode.title ??
                                                  'Untitled Episode',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: width * 0.045,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                            SizedBox(width: width * 0.03),
                                            AnimatedOpacity(
                                              opacity: isSelected ? 1.0 : 0.0,
                                              duration: const Duration(
                                                milliseconds: 800,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: width * 0.015,
                                                ),
                                                child: Image.asset(
                                                  "assets/images/icon_image.png",
                                                  height: height * 0.04,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.broken_image,
                                                        size: 24,
                                                        color: Colors.white70,
                                                      ),
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
                                          episode.description ??
                                              'No description available',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: width * 0.03,
                                            fontWeight: FontWeight.w400,
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
                                          AnimatedOpacity(
                                            opacity: isPlaying ? 1.0 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 50,
                                            ),
                                            child: SizedBox(
                                              width: width * 0.09,
                                              height: width * 0.09,
                                              child: CustomPaint(
                                                painter: GradientProgressPainter(
                                                  progress:
                                                      _totalDuration
                                                                  .inMilliseconds >
                                                              0
                                                          ? _currentDuration
                                                                  .inMilliseconds /
                                                              _totalDuration
                                                                  .inMilliseconds
                                                          : 0.0,
                                                  strokeWidth: 4,
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xff3B02DE),
                                                          Color(0xffFF002B),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          AnimatedCrossFade(
                                            firstChild: SvgPicture.asset(
                                              "assets/images/play_icon.svg",
                                              width: width * 0.05,
                                              height: width * 0.05,
                                            ),
                                            secondChild: Icon(
                                              Icons.pause_circle,
                                              color: Colors.white,
                                              size: width * 0.09,
                                            ),
                                            crossFadeState:
                                                isPlaying
                                                    ? CrossFadeState.showSecond
                                                    : CrossFadeState.showFirst,
                                            duration: const Duration(
                                              milliseconds: 100,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const SizedBox.shrink(),
                                            onPressed:
                                                () => _playEpisode(index),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(
                                              minWidth: width * 0.09,
                                              minHeight: width * 0.09,
                                            ),
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
                          )
                          : Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(width * 0.03),
                            ),
                            padding: EdgeInsets.all(width * 0.03),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              episode.title ??
                                                  'Untitled Episode',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: width * 0.045,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: width * 0.03),
                                          AnimatedOpacity(
                                            opacity: isSelected ? 1.0 : 0.0,
                                            duration: const Duration(
                                              milliseconds: 800,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: width * 0.015,
                                              ),
                                              child: Image.asset(
                                                "assets/images/icon_image.png",
                                                height: height * 0.04,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.broken_image,
                                                      size: 24,
                                                      color: Colors.white70,
                                                    ),
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
                                        episode.description ??
                                            'No description available',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: width * 0.03,
                                          fontWeight: FontWeight.w400,
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
                                        AnimatedOpacity(
                                          opacity: isPlaying ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 800,
                                          ),
                                          child: SizedBox(
                                            width: width * 0.09,
                                            height: width * 0.09,
                                            child: CustomPaint(
                                              painter: GradientProgressPainter(
                                                progress:
                                                    _totalDuration
                                                                .inMilliseconds >
                                                            0
                                                        ? _currentDuration
                                                                .inMilliseconds /
                                                            _totalDuration
                                                                .inMilliseconds
                                                        : 0.0,
                                                strokeWidth: 4,
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xff3B02DE),
                                                    Color(0xffFF002B),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        AnimatedCrossFade(
                                          firstChild: SvgPicture.asset(
                                            "assets/images/play_icon.svg",
                                            width: width * 0.06,
                                            height: width * 0.06,
                                          ),
                                          secondChild: Icon(
                                            Icons.pause_circle,
                                            color: Colors.white,
                                            size: width * 0.09,
                                          ),
                                          crossFadeState:
                                              isPlaying
                                                  ? CrossFadeState.showSecond
                                                  : CrossFadeState.showFirst,
                                          duration: const Duration(
                                            milliseconds: 100,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const SizedBox.shrink(),
                                          onPressed: () => _playEpisode(index),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: width * 0.09,
                                            minHeight: width * 0.09,
                                          ),
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
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
