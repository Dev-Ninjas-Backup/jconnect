import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:jconnect/core/common/constants/app_colors.dart';

/// Messenger-style voice message player widget in chat bubbles
class VoiceMessageBubbleWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMine;

  const VoiceMessageBubbleWidget({
    super.key,
    required this.audioUrl,
    required this.isMine,
  });

  @override
  State<VoiceMessageBubbleWidget> createState() =>
      _VoiceMessageBubbleWidgetState();
}

class _VoiceMessageBubbleWidgetState extends State<VoiceMessageBubbleWidget> {
  static AudioPlayer? _activePlayer;

  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      final dur = await _audioPlayer.setUrl(widget.audioUrl);
      if (mounted) {
        setState(() {
          _duration = dur ?? Duration.zero;
        });
      }
    } catch (_) {}

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing &&
              state.processingState != ProcessingState.completed;
          if (state.processingState == ProcessingState.completed) {
            if (_activePlayer == _audioPlayer) {
              _activePlayer = null;
            }
            _position = Duration.zero;
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.pause();
          }
        });
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_activePlayer == _audioPlayer) {
      _activePlayer = null;
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      if (_activePlayer == _audioPlayer) {
        _activePlayer = null;
      }
    } else {
      if (_activePlayer != null && _activePlayer != _audioPlayer) {
        try {
          await _activePlayer!.pause();
        } catch (_) {}
      }
      _activePlayer = _audioPlayer;

      if (_position >= _duration && _duration > Duration.zero) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play();
    }
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: 240,
      decoration: BoxDecoration(
        color: widget.isMine ? AppColors.redColor : Colors.grey[850],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5),
                    trackHeight: 3,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: Colors.white,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    value: _position.inMilliseconds
                        .clamp(
                            0,
                            _duration.inMilliseconds > 0
                                ? _duration.inMilliseconds
                                : 1)
                        .toDouble(),
                    onChanged: (val) {
                      _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _duration > Duration.zero
                          ? _formatDuration(_duration)
                          : 'Voice',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
