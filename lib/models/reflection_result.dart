class ReflectionResult {
  final String reflectionText;
  final String? suggestedAction;
  final String? disclaimer;

  const ReflectionResult({
    required this.reflectionText,
    this.suggestedAction,
    this.disclaimer,
  });
}
