part of peg.general_parser.production_rule_generator;

class ProductionRuleGenerator extends DeclarationGenerator {
  static const String VARIABLE_RESULT = "\$\$";

  static const String _ADD_TO_CACHE = MethodAddToCacheGenerator.NAME;

  static const String _CACHE_POS = ParserClassGenerator.CACHE_POS;

  static const String _CACHEABLE = ParserClassGenerator.CACHEABLE;

  static const String _CURSOR = ParserClassGenerator.CURSOR;

  static const String _GET_FROM_CACHE = MethodGetFromCacheGenerator.NAME;

  static const String _RESULT = VARIABLE_RESULT;

  static const String _SUCCESS = ParserClassGenerator.SUCCESS;

  static const String _TOKEN = ParserClassGenerator.TOKEN;

  static const String _TOKEN_START = ParserClassGenerator.TOKEN_START;

  static const String _TRACE = MethodTraceGenerator.NAME;

  static const String _TEMPLATE_TOKEN_EPILOG = '_TEMPLATE_TOKEN_EPILOG';

  static const String _TEMPLATE_TOKEN_PROLOG = '_TEMPLATE_TOKEN_PROLOG';

  static const String _TEMPLATE_WITH_CACHE = '_TEMPLATE_WITH_CACHE';

  static const String _TEMPLATE_WITHOUT_CACHE = '_TEMPLATE_WITHOUT_CACHE';

  static const String _TEMPLATE = '_TEMPLATE';

  static const String _TEMPLATE_TEST_RULE = '_TEMPLATE_TEST_RULE';

  static const String PREFIX_PARSE = 'parse_';

  static String _templateTokenEpilog = '''
$_TOKEN = null;
$_TOKEN_START = null;''';

  static String _templateTokenProlog = '''
$_TOKEN = {{TOKEN_ID}};
$_TOKEN_START = $_CURSOR;''';

  static String _templateWithCache = '''
dynamic {{NAME}}() {
  {{#COMMENTS}}
  {{#ENTER}}
  {{#VARIABLES}}          
  var pos = $_CURSOR;             
  if($_CACHE_POS[{{RULE_ID}}] >= pos) {
    $_RESULT = $_GET_FROM_CACHE({{RULE_ID}});
    if($_RESULT != null) {
      {{#LEAVE_CACHE}}
      return $_RESULT[0];       
    }
  } else {
    $_CACHE_POS[{{RULE_ID}}] = pos;
  }  
  {{#TOKEN_PROLOG}}    
  {{#EXPRESSION}}
  if ($_CACHEABLE[{{RULE_ID}}]) {
    $_ADD_TO_CACHE($_RESULT, pos, {{RULE_ID}});
  }    
  {{#TOKEN_EPILOG}}
  {{#LEAVE}}        
  return $_RESULT;
}
''';

  static String _templateWithoutCache = '''
dynamic {{NAME}}() {
  {{#COMMENTS}}
  {{#ENTER}}    
  {{#VARIABLES}}
  {{#TOKEN_PROLOG}}  
  {{#EXPRESSION}}
  {{#TOKEN_EPILOG}}
  {{#LEAVE}}    
  return $_RESULT;
}
''';

  final GeneralParserClassGenerator parserClassGenerator;

  final ProductionRule productionRule;

  Map<String, int> _blockVariables = new Map<String, int>();

  //OrderedChoiceExpressionGenerator _expressionGenerator;
  OrderedChoiceExpressionGenerator _expressionGenerator;

  List<Generator> generators = [];

  ParserGeneratorOptions _options;

  GeneralParserGenerator _parserGenerator;
  Map<String, int> _variables = new Map<String, int>();

  ProductionRuleGenerator(this.productionRule, this.parserClassGenerator) {
    if (productionRule == null) {
      throw new ArgumentError('productionRule: $productionRule');
    }

    if (parserClassGenerator == null) {
      throw new ArgumentError('parserClassGenerator: $parserClassGenerator');
    }

    _parserGenerator = parserClassGenerator.parserGenerator;
    _options = _parserGenerator.options;
    //_expressionGenerator = new OrderedChoiceExpressionGenerator(productionRule.expression, this);
    _expressionGenerator = new OrderedChoiceExpressionGenerator(productionRule.expression, this);
    addTemplate(_TEMPLATE_TOKEN_EPILOG, _templateTokenEpilog);
    addTemplate(_TEMPLATE_TOKEN_PROLOG, _templateTokenProlog);
    addTemplate(_TEMPLATE_WITH_CACHE, _templateWithCache);
    addTemplate(_TEMPLATE_WITHOUT_CACHE, _templateWithoutCache);
  }

  static String getMethodName(ProductionRule productionRule) {
    if (productionRule == null) {
      throw new ArgumentError("productionRule: $productionRule");
    }

    if (!productionRule.isStartingRule) {
      return '_${PREFIX_PARSE}${productionRule.name}';
    }

    return '${PREFIX_PARSE}${productionRule.name}';
  }

  String get name {
    return getMethodName(productionRule);
  }

  ParserGeneratorOptions get options => _options;

  GeneralParserGenerator get parserGenerator => _parserGenerator;

  String allocateVariable(String name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (_variables[name] == null) {
      _variables[name] = 0;
    }

    return '$name${_variables[name]++}';
  }

  String allocateBlockVariable(String name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (_blockVariables[name] == null) {
      _blockVariables[name] = 0;
    }

    return '$name${_blockVariables[name]++}';
  }

  List<String> generate() {
    var useCache = options.memoize;
    if (productionRule.numberOfCalls - productionRule.numberOfOwnCalls < 2) {
      useCache = false;
    }

    // TODO: Memoization: productionRule.expression.isOptional
    if (productionRule.expression.isOptional) {
      useCache = false;
    }

    if (productionRule.isMorpheme) {
      useCache = false;
    }

    if (useCache) {
      return _generateWithCache();
    } else {
      return _generateWithoutCache();
    }
  }

  void _assignTraceVariables(TemplateBlock block) {
    var name = productionRule.name;
    block.assign('#ENTER', "$_TRACE('$name', '${Trace.getTraceState(enter: true, success: true)}');");
    var success = Trace.getTraceState(enter: false, success: true);
    var failed = Trace.getTraceState(enter: false, success: false);
    block.assign('#LEAVE', "$_TRACE('$name', ($_SUCCESS ? '$success' : '$failed'));");
  }

  void _assignTraceVariablesWithCache(TemplateBlock block) {
    var name = productionRule.name;
    block.assign('#ENTER', "$_TRACE('$name', '${Trace.getTraceState(enter: true, success: true)}');");
    var success = Trace.getTraceState(cached: true, enter: false, success: true);
    var failed = Trace.getTraceState(cached: true, enter: false, success: false);
    block.assign('#LEAVE_CACHE', "$_TRACE('$name', ($_SUCCESS ? '$success' : '$failed'));");
  }

  List<String> _generateTokenEpilog() {
    if (!productionRule.isLexeme) {
      //if (!productionRule.isLexical) {
      return const <String>[];
    }

    var block = getTemplateBlock(_TEMPLATE_TOKEN_EPILOG);
    return block.process();
  }

  List<String> _generateTokenProlog() {
    if (!productionRule.isLexeme) {
      //if (!productionRule.isLexical) {
      return const <String>[];
    }

    var block = getTemplateBlock(_TEMPLATE_TOKEN_PROLOG);
    block.assign("TOKEN_ID", productionRule.tokenId);
    return block.process();
  }

  List<String> _generateVariables() {
    var strings = [];
    for (var name in _variables.keys) {
      var last = _variables[name];
      var names = [];
      for (var i = 0; i <= last; i++) {
        names.add('$name$i');
      }

      strings.add('var ${names.join(', ')};');
    }

    strings.add('var $_RESULT;');
    return strings;
  }

  List<String> _generateWithCache() {
    var block = getTemplateBlock(_TEMPLATE_WITH_CACHE);
    var methodName = getMethodName(productionRule);
    if (_options.comment) {
      var lexical = _getLexicalType();
      block.assign('#COMMENTS', '// $lexical');
      block.assign('#COMMENTS', '// $productionRule');
    }

    if (productionRule.isLexeme) {
      block.assign('#TOKEN_EPILOG', _generateTokenEpilog());
      block.assign('#TOKEN_PROLOG', _generateTokenProlog());
    }

    if (_options.trace) {
      _assignTraceVariables(block);
    }

    block.assign('#EXPRESSION', _expressionGenerator.generate());
    block.assign('#VARIABLES', _generateVariables());
    //block.assign('#FLAGS', _setFlag());
    block.assign('NAME', methodName);

    var block2 = new TemplateBlock(_templateWithCache);
    block.assign('RULE_ID', productionRule.id);
    return block.process();
  }

  List<String> _generateWithoutCache() {
    var block = getTemplateBlock(_TEMPLATE_WITHOUT_CACHE);
    var methodName = getMethodName(productionRule);
    if (_options.comment) {
      var lexical = _getLexicalType();
      block.assign('#COMMENTS', '// $lexical');
      block.assign('#COMMENTS', '// $productionRule');
    }

    if (productionRule.isLexeme) {
      block.assign('#TOKEN_EPILOG', _generateTokenEpilog());
      block.assign('#TOKEN_PROLOG', _generateTokenProlog());
    }

    if (_options.trace) {
      _assignTraceVariables(block);
    }

    block.assign('#EXPRESSION', _expressionGenerator.generate());
    block.assign('#VARIABLES', _generateVariables());
    //block.assign('#FLAGS', _setFlag());
    block.assign('NAME', methodName);
    return block.process();
  }

  String _getLexicalType() {
    switch (productionRule.kind) {
      case ProductionRuleKinds.LEXEME:
        return 'LEXEME (TOKEN)';
      case ProductionRuleKinds.MORHEME:
        return 'MORHEME';
      case ProductionRuleKinds.SENTENCE:
        return 'SENTENCE (NONTERMINAL)';
      default:
        return "";
    }
  }
}
