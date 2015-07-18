import 'package:barback/barback.dart';
import 'package:peg/peg_parser.dart';
import 'package:peg/grammar/grammar.dart';
import 'package:parser_error/parser_error.dart';
import 'package:peg/grammar_analyzer/grammar_analyzer.dart';
import 'package:peg/general_parser/parser_generator.dart';
import 'package:peg/parser_generator/parser_generator_options.dart';
import 'package:path/path.dart' as path;
import 'package:strings/strings.dart';
import 'dart:async';

/// This transformer rewrites the dart files into the generated parser generated by peg.
///
/// For example, you should create two files: 'bin/arithmetic_parser.dart' and 'bin/arithmetic_parser.peg'.
/// Both files should have the same name and should be in the same directory
class PegTransformer extends Transformer {
  final BarbackSettings _settings;

  PegTransformer.asPlugin(this._settings);

  /// Since we are not able to modify the output of an asset, the only allowed extension is '.dart'.
  /// We are not able to use a '.peg' extension.
  String get allowedExtensions => ".dart";

  @override
  Future apply(Transform transform) async {
    var pId = transform.primaryInput.id;
    var id = pId.changeExtension('.peg');
    var pegAsset;

    try {
      pegAsset = await transform.getInput(id);
    } catch(e) {
      // if the peg asset is not found do nothing
      return;
    }

    var content = await pegAsset.readAsString();

    var basename = path.basenameWithoutExtension(id.path);

    var parser = new PegParser(content);
    var grammar = _parseGrammar(parser);
    var options = new ParserGeneratorOptions.fromMap(_settings.configuration);

    var name = camelize(basename) + 'Parser';

    var generated = new GeneralParserGenerator(name, grammar, options).generate().join('\n');

    transform.addOutput(new Asset.fromString(pId, generated));
  }

  Grammar _parseGrammar(PegParser parser) {
    var grammar = parser.parse_Grammar();
    if (!parser.success) {
      var messages = [];
      for (var error in parser.errors()) {
        messages.add(new ParserErrorMessage(error.message, error.start, error.position));
      }

      var strings = ParserErrorFormatter.format(parser.text, messages);
      print(strings.join("\n"));
      throw new FormatException();
    }

    var grammarAnalyzer = new GrammarAnalyzer();
    var warnings = grammarAnalyzer.analyze(grammar);
    if (!warnings.isEmpty) {
      for (var warning in warnings) {
        print(warning);
      }
    }

    return grammar;
  }
}