part of peg.grammar_generator;

class MethodTraceGenerator extends TemplateGenerator {
  static const String NAME = "_trace";

  static const String _INPUT_POS = GrammarGenerator.VARIABLE_INPUT_POS;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template =
      '''
void $NAME(String rule, String prefix) {
  _calculatePos(_inputPos);
  var message = "\$prefix \$line, \$column: \$rule";
  if (message.length > {{LENGTH}}) {
    message = message.substring(0, {{LENGTH}});
  } else {
    message = message.padRight({{LENGTH}});
  }

  var position = " (\$_inputPos)";
  var rest = 80 - position.length + 2 - message.length;
  var source = <String>[];
  for (var i = _inputPos; i < _inputLen; i++) {
    var s = _text[i];
    var c = _text.codeUnitAt(i);
    switch (c) {
      case 9:
        s = "\\\\t";
        break;
      case 10:
        s = "\\\\n";
        break;
      case 13:
        s = "\\\\r";
        break;
    }
    var length = s.length;
    if (rest - length > 0) {
      rest -= length;
      source.add(s);
    } else {
      break;
    }
  }

  message += source.join();
  message.padRight(80 - position.length);
  message += position;
  print(message);    
}
''';

  int _length;

  MethodTraceGenerator(int length) {
    if (length == null || length < 0) {
      throw new ArgumentError("length: $length");
    }

    _length = length;
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    var length = _length + 14;
    if (length > 60) {
      length = 60;
    }

    block.assign("LENGTH", length);
    return block.process();
  }
}