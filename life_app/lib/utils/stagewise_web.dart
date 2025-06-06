import 'dart:html' as html;

class StagewiseImplementation {
  static void injectStagewiseScript() {
    final script = html.ScriptElement()
      ..src = 'https://unpkg.com/@stagewise/toolbar@latest/dist/index.js'
      ..type = 'module';
    
    script.onLoad.listen((_) {
      // Initialize stagewise with empty plugins
      final initScript = html.ScriptElement()
        ..text = '''
        if (window.Stagewise) {
          window.Stagewise.initToolbar({
            plugins: []
          });
        }
      ''';
      html.document.body!.append(initScript);
    });

    html.document.head!.append(script);
  }
} 