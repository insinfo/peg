part of peg.grammar_generator;

class MethodMatchRangeGenerator extends TemplateGenerator {
  static const String NAME = "_matchRange";

  static const String _CH = GrammarGenerator.VARIABLE_CH;

  static const String _CURSOR = GrammarGenerator.VARIABLE_CURSOR;

  static const String _EOF = GrammarGenerator.CONSTANT_EOF;

  static const String _FAILURE = MethodFailureGenerator.NAME;

  static const String _INPUT = GrammarGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = GrammarGenerator.VARIABLE_INPUT_LEN;

  static const String _SUCCESS = GrammarGenerator.VARIABLE_SUCCESS;

  static const String _TESTING = GrammarGenerator.VARIABLE_TESTING;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
String $NAME(int start, int end) {
  $_SUCCESS = $_CH >= start && $_CH <= end;
  if ($_SUCCESS) { 
    var result = $_INPUT[$_CURSOR++];
    if ($_CURSOR < $_INPUT_LEN) {
      $_CH = $_INPUT.codeUnitAt($_CURSOR);
    } else {
      $_CH = $_EOF;
    }  
    return result;
  }
  if ($_CURSOR > $_TESTING) {
    $_FAILURE();
  }  
  return null;  
}
''';

  MethodMatchRangeGenerator() {
    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    return block.process();
  }
}
