import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import '../../detailsScreen/model/episode_model.dart';

class PlayerScreen extends StatefulWidget {
  final Episode episode;
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  const PlayerScreen({
    super.key,
    required this.episode,
    required this.audioPlayer,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    if (!widget.isPlaying) {
      widget.onPlayPause();
    }

    widget.audioPlayer.durationStream.listen((d) {
      if (d != null && mounted) {
        setState(() => _duration = d);
      }
    });

    widget.audioPlayer.setSpeed(_playbackSpeed);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeSpeed() {
    setState(() {
      _playbackSpeed =
          _playbackSpeed == 1.0
              ? 1.25
              : _playbackSpeed == 1.25
              ? 1.5
              : 1.0;
      widget.audioPlayer.setSpeed(_playbackSpeed);
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              SvgPicture.asset(
                "assets/images/Send_icon.svg",
                width: 24,
                height: 24,
              ),
            ],
          ),
          const SizedBox(width: 5),
          Image.asset("assets/images/icon_image.png"),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/podcast_cover.png',
                    width: width * 0.9,
                    height: width * 0.9,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    widget.episode.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Media3 Labs LLC",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.episode.description ?? "",
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              /// Playback Speed
              GestureDetector(
                onTap: _changeSpeed,
                child: AnimatedContainer(
                  duration: const Duration(microseconds: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(microseconds: 3),
                    transitionBuilder:
                        (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                    child: Text(
                      key: ValueKey<double>(_playbackSpeed),
                      "${_playbackSpeed.toStringAsFixed(2)}x",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<Duration>(
                  stream: widget.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final progressPercent =
                        (_duration.inSeconds > 0)
                            ? (position.inSeconds / _duration.inSeconds).clamp(
                              0.0,
                              1.0,
                            )
                            : 0.0;

                    return Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final sliderWidth = constraints.maxWidth;

                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Container(
                                  height: 4,
                                  width: sliderWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  height: 4,
                                  width: sliderWidth * progressPercent,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xff3B02DE),
                                        Color(0xffFF002B),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    inactiveTrackColor: Colors.transparent,
                                    activeTrackColor: Colors.transparent,
                                    thumbColor: Colors.white,
                                    overlayColor: Colors.white24,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14,
                                    ),
                                  ),
                                  child: Slider(
                                    value: position.inSeconds.toDouble(),
                                    min: 0.0,
                                    max: _duration.inSeconds.toDouble().clamp(
                                      0.0,
                                      double.infinity,
                                    ),
                                    onChanged: (double value) {
                                      widget.audioPlayer.seek(
                                        Duration(seconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              /// Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: widget.hasPrevious ? Colors.white : Colors.white30,
                    ),
                    iconSize: 30,
                    onPressed: widget.hasPrevious ? widget.onPrevious : null,
                  ),
                  const SizedBox(width: 16),

                  // 10-second rewind
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    iconSize: 30,
                    onPressed: () async {
                      final currentPos = await widget.audioPlayer.position;
                      final newPos = currentPos - const Duration(seconds: 10);
                      widget.audioPlayer.seek(
                        newPos > Duration.zero ? newPos : Duration.zero,
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Play/Pause button with gradient
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                      child: IconButton(
                        key: ValueKey<bool>(widget.isPlaying),
                        icon: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              colors: [Color(0xff3B02DE), Color(0xffFF002B)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: Icon(
                            widget.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: widget.onPlayPause,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 10-second forward
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    iconSize: 30,
                    onPressed: () async {
                      final currentPos = await widget.audioPlayer.position;
                      final newPos = currentPos + const Duration(seconds: 10);
                      if (_duration != Duration.zero && newPos < _duration) {
                        widget.audioPlayer.seek(newPos);
                      }
                    },
                  ),

                  const SizedBox(width: 16),

                  // Next Episode
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: widget.hasNext ? Colors.white : Colors.white30,
                    ),
                    iconSize: 30,
                    onPressed: widget.hasNext ? widget.onNext : null,
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
