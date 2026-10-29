enum ReflectionSource { gemini, localFallback }

class ReflectionResult {
  final String reflectionText;
  final String? suggestedAction;
  final String? disclaimer;
  final ReflectionSource source;

  const ReflectionResult({
    required this.reflectionText,
    this.suggestedAction,
    this.disclaimer,
    this.source = ReflectionSource.localFallback,
  });
}
