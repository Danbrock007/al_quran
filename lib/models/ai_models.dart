class Evidence {
  const Evidence({required this.label, required this.reference, this.text = ''});
  final String label;
  final String reference;
  final String text;

  factory Evidence.fromJson(Map<String, dynamic> json) => Evidence(
        label: json['label']?.toString() ?? 'Reference',
        reference: json['reference']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
      );
}

class AssistantAnswer {
  const AssistantAnswer({
    required this.answer,
    required this.evidence,
    required this.disclaimer,
  });
  final String answer;
  final List<Evidence> evidence;
  final String disclaimer;
}
