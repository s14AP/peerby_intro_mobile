// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

Future<void> loadMapsScript(String apiKey) {
  final Completer<void> completer = Completer<void>();
  final html.ScriptElement script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..async = true;
  script.onLoad.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.listen((_) {
    if (!completer.isCompleted) completer.complete();
  });
  html.document.head!.append(script);
  return completer.future;
}
