import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uruvia/constants/colors.dart';
import 'package:uruvia/widgets/custom_text.dart';
import 'package:uruvia/services/voice_expense_service.dart';
import 'package:uruvia/services/vocabulary_map.dart';
import 'package:uruvia/offline/database_helper.dart';

class VoiceExpensePage extends StatefulWidget {
  const VoiceExpensePage({super.key});

  @override
  State<VoiceExpensePage> createState() => _VoiceExpensePageState();
}

class _VoiceExpensePageState extends State<VoiceExpensePage> {
  final VoiceExpenseService _voiceService = VoiceExpenseService();
  bool _isListening = false;
  bool _isInitialized = false;
  String _transcribedText = '';
  String _initializationError = '';
  bool _showDisclosure = true;

  @override
  void initState() {
    super.initState();
    _checkDisclosureStatus();
  }

  Future<void> _checkDisclosureStatus() async {
    final hasSeen = await DatabaseHelper.instance.getSetting('has_seen_voice_permission_disclosure', defaultValue: false);
    if (hasSeen) {
      if (mounted) {
        setState(() {
          _showDisclosure = false;
        });
        _initSpeech();
      }
    } else {
      if (mounted) {
        setState(() {
          _showDisclosure = true;
        });
      }
    }
  }

  Future<void> _initSpeech() async {
    final available = await _voiceService.initialize(
      onStatus: (status) {
        print("Speech Status: $status");
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }
      },
      onError: (error) {
        print("Speech Error: $error");
        if (mounted) {
          setState(() {
            _isListening = false;
            _initializationError = error;
          });
        }
      },
    );
    
    if (mounted) {
      setState(() {
        _isInitialized = available;
        if (!available) {
          _initializationError = "Speech recognition not available. Please check permissions.";
          _showDisclosure = true;
          DatabaseHelper.instance.setSetting('has_seen_voice_permission_disclosure', false);
        } else {
          _startListening();
        }
      });
    }
  }

  void _startListening() async {
    if (!_isInitialized) return;
    setState(() {
      _isListening = true;
      _transcribedText = '';
      _initializationError = '';
    });
    try {
      await _voiceService.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _transcribedText = text;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _initializationError = e.toString();
        });
      }
    }
  }

  void _stopListening() async {
    await _voiceService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    _voiceService.cancelListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showDisclosure) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Drag Handle
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 36.0,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.25),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // 2. Icon and Title
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEFF6FF),
                ),
                child: const Icon(
                  CupertinoIcons.mic_circle_fill,
                  color: ConstantColor.blueBackground,
                  size: 48.0,
                ),
              ),
              const SizedBox(height: 16.0),
              googleSansText(
                text: "Enable Voice Logging",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 20.0,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.0),
              googleSansText(
                text: "To quickly log expenses by speaking, Uruvia requires Microphone and Speech-to-Text permissions. These features enable Uruvia to hear and transcribe your voice logs locally on your device.",
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.normal,
                size: 13.5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),

              // 3. Disclosure Details List
              _buildDisclosureRow(
                icon: CupertinoIcons.mic_fill,
                title: "Microphone Access",
                description: "Used to capture your voice when recording an expense log.",
              ),
              const SizedBox(height: 16.0),
              _buildDisclosureRow(
                icon: CupertinoIcons.waveform,
                title: "Speech Recognition",
                description: "Processes and transcribes your audio into text locally on this device.",
              ),
              const SizedBox(height: 32.0),

              // 4. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: googleSansText(
                        text: "Not Now",
                        colors: const Color(0xFF475569),
                        fontWeight: FontWeight.bold,
                        size: 14.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await DatabaseHelper.instance.setSetting('has_seen_voice_permission_disclosure', true);
                        if (mounted) {
                          setState(() {
                            _showDisclosure = false;
                          });
                          _initSpeech();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: ConstantColor.blueBackground,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: googleSansText(
                        text: "Enable",
                        colors: Colors.white,
                        fontWeight: FontWeight.bold,
                        size: 14.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Drag Handle
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 36.0,
                height: 4.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.25),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // 2. Header Row
            Row(
              children: [
                Icon(
                  Platform.isAndroid ? Icons.mic : CupertinoIcons.mic,
                  color: const Color(0xFF64748B),
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                googleSansText(
                  text: "Voice Entry",
                  colors: ConstantColor.headingTextPrimary,
                  fontWeight: FontWeight.bold,
                  size: 16.5,
                ),
                const Spacer(),
                // Refresh Button
                IconButton(
                  onPressed: () {
                    _startListening();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: googleSansText(
                          text: "Restarting speech recognition...",
                          colors: Colors.white,
                          fontWeight: FontWeight.normal,
                          size: 14.0,
                        ),
                        backgroundColor: ConstantColor.blueBackground,
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                  icon: const Icon(
                    CupertinoIcons.arrow_counterclockwise,
                    color: Color(0xFF94A3B8),
                    size: 18.0,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8.0),
                ),
                const SizedBox(width: 8.0),
                // Close button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFF64748B),
                    size: 18.0,
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8.0),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Color(0xFFF1F5F9), height: 1.0),
            ),
            const SizedBox(height: 12.0),

            // 3. Prompt or Transcribed Text Section
            googleSansText(
              text: _transcribedText.isNotEmpty ? "Transcription" : "Say what you bought, e.g.,",
              colors: ConstantColor.paragraphTextSecondary,
              fontWeight: FontWeight.normal,
              size: 13.0,
            ),
            const SizedBox(height: 10.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _transcribedText.isNotEmpty ? Colors.white : const Color(0xFFF2F6FE),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: _transcribedText.isNotEmpty ? const Color(0xFFE2E8F0) : const Color(0xFFE3EDFB),
                ),
              ),
              child: googleSansText(
                text: _transcribedText.isNotEmpty
                    ? _transcribedText
                    : "\"Bought diesel 20 litres for 12,000 naira\"",
                colors: ConstantColor.headingTextPrimary,
                fontWeight: _transcribedText.isNotEmpty ? FontWeight.normal : FontWeight.bold,
                size: 14.5,
                textAlign: TextAlign.center,
              ),
            ),
            if (_initializationError.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              googleSansText(
                text: _initializationError,
                colors: Colors.redAccent,
                fontWeight: FontWeight.bold,
                size: 12.0,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 36.0),

            // 4. Concentric Pulsing Listening Circles
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 170.0,
                  height: 170.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEFF6FF),
                      width: 1.5,
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 125.0,
                  height: 125.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDBEAFE),
                      width: 1.5,
                    ),
                  ),
                ),
                // Faint inner ring
                Container(
                  width: 96.0,
                  height: 96.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEFF6FF).withOpacity(0.4),
                  ),
                ),
                // Inner Microphone Circle Button
                GestureDetector(
                  onTap: _isInitialized ? _toggleListening : _initSpeech,
                  child: Container(
                    width: 74.0,
                    height: 74.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E293B),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.3),
                          blurRadius: 12.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_off,
                      color: Colors.white,
                      size: 26.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // 5. Soundwave Visualizer Bars
            AnimatedOpacity(
              opacity: _isListening ? 1.0 : 0.2,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                height: 32.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildSoundwaveBar(12.0),
                    _buildSoundwaveBar(24.0),
                    _buildSoundwaveBar(16.0),
                    _buildSoundwaveBar(32.0),
                    _buildSoundwaveBar(20.0),
                    _buildSoundwaveBar(28.0),
                    _buildSoundwaveBar(14.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30.0),

            // 6. Speech Processing Pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 5.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.chart_pie,
                    color: Color(0xFF3B82F6),
                    size: 12.0,
                  ),
                  const SizedBox(width: 6.0),
                  googleSansText(
                    text: "LOCAL SPEECH PROCESSING",
                    colors: const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                    size: 9.5,
                  ),
                  const SizedBox(width: 8.0),
                  // PRO badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5.0,
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      "PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.0,
                        fontWeight: FontWeight.w900,
                        fontFamily: "Inter",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // 7. Footer Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _stopListening();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: googleSansText(
                      text: "Cancel",
                      colors: const Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                      size: 14.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _transcribedText.trim().isEmpty
                        ? null
                        : () {
                            _stopListening();
                            final parsedResult = parseExpenseFromText(_transcribedText);
                            Navigator.pop(context, parsedResult);
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: _transcribedText.trim().isEmpty
                          ? Colors.grey.shade100
                          : const Color(0xFFEFF6FF),
                      foregroundColor: _transcribedText.trim().isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: googleSansText(
                      text: "Confirm",
                      colors: _transcribedText.trim().isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      size: 14.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  // Soundwave visualizer bar helper
  Widget _buildSoundwaveBar(double height) {
    return Container(
      width: 3.5,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(1.75),
      ),
    );
  }

  Widget _buildDisclosureRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF475569),
            size: 20.0,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              googleSansText(
                text: title,
                colors: ConstantColor.headingTextPrimary,
                fontWeight: FontWeight.bold,
                size: 14.0,
              ),
              const SizedBox(height: 2.0),
              googleSansText(
                text: description,
                colors: ConstantColor.paragraphTextSecondary,
                fontWeight: FontWeight.normal,
                size: 12.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
