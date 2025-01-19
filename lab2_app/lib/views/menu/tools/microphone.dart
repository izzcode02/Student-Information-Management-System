import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';

class Microphone extends StatefulWidget {
  const Microphone({super.key});

  @override
  State<Microphone> createState() => _MicrophoneState();
}

class _MicrophoneState extends State<Microphone> {
  String? audioPath;
  bool showPlayer = false;
  List<String> recordedFiles = []; // List to store file paths

  @override
  void initState() {
    super.initState();
    _loadRecordedFiles();
  }

  // Load all recorded files from the app directory
  Future<void> _loadRecordedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory
        .listSync()
        .where((item) {
          return item.path.endsWith('.m4a'); // Only include audio files
        })
        .map((e) => e.path)
        .toList();

    setState(() {
      recordedFiles = files;
    });
  }

  void _startRecording() {
    setState(() {
      showPlayer = false;
      audioPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microphone'),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Microphone Recording List',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                Gap(25),
                if (recordedFiles.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 1,
                    child: ListView.builder(
                      itemCount: recordedFiles.length,
                      itemBuilder: (context, index) {
                        final filePath = recordedFiles[index];
                        return ListTile(
                          title: Text('Recording ${index + 1}'),
                          subtitle: Text(filePath),
                          onTap: () {
                            setState(() {
                              audioPath = filePath;
                              showPlayer = true;
                            });
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteRecording(filePath);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                if (!showPlayer)
                  Recorder(
                    onStop: (path) {
                      setState(() {
                        audioPath = path;
                        showPlayer = true;
                        recordedFiles
                            .add(path); // Add the new recording to the list
                      });
                    },
                  ),
                if (showPlayer && audioPath != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: AudioPlayer(
                      source: audioPath!,
                      onDelete: () {
                        _deleteRecording(audioPath!);
                      },
                      onRecordAgain: _startRecording,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteRecording(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        recordedFiles.remove(filePath); // Remove the file from the list
        if (audioPath == filePath) {
          showPlayer = false;
          audioPath = null; // Reset player when deleted
        }
      });
    }
  }
}

mixin AudioRecorderMixin {
  Future<void> recordFile(AudioRecorder recorder, RecordConfig config) async {
    final path = await _getPath();
    await recorder.start(config, path: path);
  }

  Future<void> recordStream(AudioRecorder recorder, RecordConfig config) async {
    final path = await _getPath();
    final file = File(path);
    final stream = await recorder.startStream(config);

    stream.listen(
      (data) {
        print(recorder.convertBytesToInt16(Uint8List.fromList(data)));
        file.writeAsBytesSync(data, mode: FileMode.append);
      },
      onDone: () {
        print('End of stream. File written to $path.');
      },
    );
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(
        dir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
  }
}

class Recorder extends StatefulWidget {
  final void Function(String path) onStop;
  const Recorder({super.key, required this.onStop});

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> with AudioRecorderMixin {
  int _recordDuration = 0;
  Timer? _timer;
  late final AudioRecorder _audioRecorder;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen(_updateRecordState);
    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
      setState(() => _amplitude = amp);
    });
    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.aacLc;
        if (!await _isEncoderSupported(encoder)) return;

        const config = RecordConfig(encoder: encoder, numChannels: 1);

        await recordFile(_audioRecorder, config);

        _recordDuration = 0;
        _startTimer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      widget.onStop(path); // Pass the path to the parent for playback
    }
  }

  Future<void> _pause() => _audioRecorder.pause();
  Future<void> _resume() => _audioRecorder.resume();

  void _updateRecordState(RecordState recordState) {
    setState(() => _recordState = recordState);
    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(encoder);
    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
    }
    return isSupported;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRecordStopControl(),
            const SizedBox(width: 20),
            _buildPauseResumeControl(),
            const SizedBox(width: 20),
            _buildText(),
          ],
        ),
        if (_amplitude != null) ...[
          const SizedBox(height: 40),
          Text('Current: ${_amplitude?.current ?? 0.0}'),
          Text('Max: ${_amplitude?.max ?? 0.0}'),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      icon = const Icon(Icons.mic, color: Colors.blue, size: 30);
      color = Colors.blue.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_recordState == RecordState.record) {
      icon = const Icon(Icons.pause, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      icon = const Icon(Icons.play_arrow, color: Colors.blue, size: 30);
      color = Colors.blue.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState == RecordState.pause) ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return const Text("Waiting to record");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    return number < 10 ? '0$number' : number.toString();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}

class AudioPlayer extends StatefulWidget {
  final String source;
  final VoidCallback onDelete;
  final VoidCallback onRecordAgain;

  const AudioPlayer({
    super.key,
    required this.source,
    required this.onDelete,
    required this.onRecordAgain,
  });

  @override
  AudioPlayerState createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioPlayer> {
  static const double _controlSize = 56;
  static const double _deleteBtnSize = 34;

  final _audioPlayer = ap.AudioPlayer()..setReleaseMode(ap.ReleaseMode.stop);
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    _playerStateChangedSubscription =
        _audioPlayer.onPlayerComplete.listen((state) async {
      await stop();
    });
    _positionChangedSubscription = _audioPlayer.onPositionChanged.listen(
      (position) => setState(() {
        _position = position;
      }),
    );
    _durationChangedSubscription = _audioPlayer.onDurationChanged.listen(
      (duration) => setState(() {
        _duration = duration;
      }),
    );

    _audioPlayer.setSource(_source);
    super.initState();
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: Material(
            color: Colors.blue.withOpacity(0.1),
            child: InkWell(
              onTap: () async {
                if (_audioPlayer.state == ap.PlayerState.playing) {
                  await pause();
                } else if (_audioPlayer.state == ap.PlayerState.paused) {
                  await resume();
                } else {
                  await play();
                }
              },
              child: SizedBox(
                width: _controlSize,
                height: _controlSize,
                child: Icon(
                  _audioPlayer.state == ap.PlayerState.playing
                      ? Icons.pause
                      : (_audioPlayer.state == ap.PlayerState.paused
                          ? Icons.play_arrow
                          : Icons.play_arrow),
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        _duration == null || _position == null
            ? const SizedBox.shrink()
            : Text(
                '${_formatNumber(_position?.inMinutes)} : ${_position?.inSeconds.remainder(60)} / ${_formatNumber(_duration?.inMinutes)} : ${_duration?.inSeconds.remainder(60)}',
                style: const TextStyle(fontSize: 14),
              ),
        const SizedBox(height: 8),
        // Delete Button
        IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: widget.onDelete,
        ),
        // "Record Again" Button to return to the normal state
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.onRecordAgain,
          child: const Text('Record Again'),
        ),
      ],
    );
  }

  Future<void> play() async {
    await _audioPlayer.play(_source);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  String _formatNumber(int? number) {
    return number != null && number < 10 ? '0$number' : number.toString();
  }

  ap.Source get _source =>
      kIsWeb ? ap.UrlSource(widget.source) : ap.DeviceFileSource(widget.source);
}
