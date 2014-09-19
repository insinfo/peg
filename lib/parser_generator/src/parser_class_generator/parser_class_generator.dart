part of peg.parser_generators.parser_class_generator;

abstract class ParserClassGenerator extends ClassGenerator {
  static const String CACHE = "_cache";

  static const String CACHE_POS = "_cachePos";

  static const String CACHE_RULE = "_cacheRule";

  static const String CACHE_STATE = "_cacheState";

  static const String CH = "_ch";

  static const String CURSOR = "_cursor";

  static const String EOF = "-1";

  static const String EXPECTED = "_expected";

  static const String FAILURE_POS = "_failurePos";

  static const String INPUT = "_input";

  static const String INPUT_LEN = "_inputLen";

  static const String SUCCESS = "success";

  static const String TOKEN = "_token";

  static const String TOKEN_LEVEL = "_tokenLevel";

  static const String TOKEN_START = "_tokenStart";

  static const String TESTING = "_testing";

  static const String TEXT = "text";

  ParserClassGenerator(String name) : super(name) {
    _addCommonMembers();
  }

  Grammar get grammar;

  ParserGeneratorOptions get options;

  ParserGenerator get parserGenerator;

  void _addCommonMembers() {
    addMethod(new MethodCompactGenerator());
    addMethod(new MethodErrorsGenerator(ParserErrorClassGenerator.getName(name)));
    addMethod(new MethodFlattenGenerator());
    addMethod(new MethodToCodePointGenerator());
    addMethod(new MethodToCodePointsGenerator());
    addMethod(new MethodResetGenerator());
    var grammar = parserGenerator.grammar;
    var options = parserGenerator.options;
    // Memoization
    if (options.memoize) {
      addMethod(new MethodAddToCacheGenerator(grammar));
      addMethod(new MethodGetFromCacheGenerator());
    }

    addVariable(new VariableGenerator(CACHE, "List"));
    addVariable(new VariableGenerator(CACHE_POS, "int"));
    addVariable(new VariableGenerator(CACHE_RULE, "List<int>"));
    addVariable(new VariableGenerator(CACHE_STATE, "List<int>"));
    addVariable(new VariableGenerator(CH, "int"));
    addVariable(new VariableGenerator(CURSOR, "int"));
    addVariable(new VariableGenerator(EXPECTED, "List<String>"));
    addVariable(new VariableGenerator(FAILURE_POS, "int"));
    addVariable(new VariableGenerator(INPUT, "List<int>"));
    addVariable(new VariableGenerator(INPUT_LEN, "int"));
    addVariable(new VariableGenerator(SUCCESS, "bool"));
    addVariable(new VariableGenerator(TESTING, "int"));
    addVariable(new VariableGenerator(TOKEN, "String"));
    addVariable(new VariableGenerator(TOKEN_LEVEL, "int"));
    addVariable(new VariableGenerator(TOKEN_START, "int"));
    addVariable(new VariableGenerator(TEXT, "final String"));
  }
}
