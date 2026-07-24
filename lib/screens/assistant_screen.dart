import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/ai_models.dart';
import '../services/assistant_service.dart';
import '../services/preferences_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _service = AssistantService();
  final _preferences = PreferencesService();
  AssistantAnswer? _answer;
  bool _loading = false;
  String _language = 'Urdu';
  String _school = 'Hanafi';

  Future<void> _ask() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _answer = null;
    });
    try {
      final answer = await _service.ask(
        question: _controller.text.trim(),
        language: _language,
        school: _school,
      );
      if (mounted) setState(() => _answer = answer);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.emerald,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Islamic AI Assistant',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const Text('Answers grounded in Quran & Hadith'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(labelText: 'Language'),
                items: const [
                  DropdownMenuItem(value: 'Urdu', child: Text('Urdu')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                ],
                onChanged: (value) async {
                  setState(() => _language = value!);
                  await _preferences.setLanguage(value!);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _school,
                decoration: const InputDecoration(labelText: 'Fiqh'),
                items: const [
                  DropdownMenuItem(value: 'Hanafi', child: Text('Hanafi')),
                  DropdownMenuItem(value: 'Shafi', child: Text('Shafi’i')),
                  DropdownMenuItem(value: 'General', child: Text('General')),
                ],
                onChanged: (value) async {
                  setState(() => _school = value!);
                  await _preferences.setSchool(value!);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _controller,
          minLines: 4,
          maxLines: 7,
          textDirection:
              _language == 'Urdu' ? TextDirection.rtl : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: _language == 'Urdu'
                ? 'Apna sawal ya masla yahan likhein…'
                : 'Write your question here…',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loading ? null : _ask,
          icon: _loading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: Text(_loading ? 'Checking references…' : 'Ask with references'),
        ),
        const SizedBox(height: 18),
        if (_answer != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Answer',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SelectableText(
                    _answer!.answer,
                    textDirection: _language == 'Urdu'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: const TextStyle(height: 1.7),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ..._answer!.evidence.map(
            (e) => Card(
              child: ListTile(
                leading: const Icon(Icons.verified_outlined,
                    color: AppColors.emerald),
                title: Text('${e.label} • ${e.reference}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: e.text.isEmpty ? null : Text(e.text),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(_answer!.disclaimer),
          ),
        ] else ...[
          const _PromptChip('Namaz mein bhool ho jaye to kya karein?'),
          const _PromptChip('What does the Quran say about patience?'),
          const _PromptChip('Safar mein namaz ka kya hukam hai?'),
        ],
      ],
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: Text(text),
        ),
      );
}
