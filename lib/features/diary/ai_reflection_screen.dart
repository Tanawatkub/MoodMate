import 'package:flutter/material.dart';

import '../../app_dependencies.dart';
import '../../models/mood_entry.dart';
import '../../models/reflection_result.dart';

class AiReflectionScreen extends StatefulWidget {
  const AiReflectionScreen({
    super.key,
    required this.dependencies,
    required this.entry,
  });

  final AppDependencies dependencies;
  final MoodEntry entry;

  @override
  State<AiReflectionScreen> createState() => _AiReflectionScreenState();
}

class _AiReflectionScreenState extends State<AiReflectionScreen> {
  late Future<ReflectionResult> _reflectionFuture;

  @override
  void initState() {
    super.initState();
    _reflectionFuture = _loadReflection();
  }

  Future<ReflectionResult> _loadReflection() {
    return widget.dependencies.reflection.reflect(
      diaryText: widget.entry.diaryText,
      mood: widget.entry.mood,
      contextTags: widget.entry.contextTags,
    );
  }

  void _retry() {
    setState(() => _reflectionFuture = _loadReflection());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('ข้อคิดเตือนใจ'),
        centerTitle: true,
      ),
      body: FutureBuilder<ReflectionResult>(
        future: _reflectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'สร้างข้อคิดไม่สำเร็จ กรุณาลองอีกครั้ง',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            );
          }

          final result = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Color(0xFFFDEADB),
                child: Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFC48E66),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'บันทึกสะท้อนใจ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        result.reflectionText,
                        style: const TextStyle(height: 1.7),
                      ),
                      if (result.suggestedAction case final action?) ...[
                        const SizedBox(height: 16),
                        Text(
                          'ลองทำถ้ารู้สึกว่าเหมาะกับคุณ: $action',
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (result.disclaimer case final disclaimer?) ...[
                const SizedBox(height: 16),
                Text(disclaimer, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 20),
              const Text(
                'ข้อคิดนี้สร้างจากบันทึกที่คุณเลือก และไม่ใช่การวินิจฉัยหรือคำแนะนำทางการแพทย์',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ],
          );
        },
      ),
    );
  }
}
