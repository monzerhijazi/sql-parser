lexer = require('../lib/lexer')

describe "SQL Lexer", ->
  it "eats select queries", ->
    tokens = lexer.tokenize("select * from my_table")
    tokens.should.eql [
      ["SELECT", "select", 1, 0]
      ["STAR", "*", 1, 7]
      ["FROM", "from", 1, 9]
      ["LITERAL", "my_table", 1, 14]
      ["EOF", "", 1, 22]
    ]

  it "eats select queries with stars and multiplication", ->
    tokens = lexer.tokenize("select * from my_table where foo = 1 * 2")
    tokens.should.eql [
      ["SELECT", "select", 1, 0]
      ["STAR", "*", 1, 7]
      ["FROM", "from", 1, 9]
      ["LITERAL", "my_table", 1, 14]
      ["WHERE", "where", 1, 23]
      ["LITERAL", "foo", 1, 29]
      ["OPERATOR", "=", 1, 33]
      ["NUMBER", "1", 1, 35]
      ["MATH_MULTI", "*", 1, 37]
      ["NUMBER", "2", 1, 39]
      ["EOF", "", 1, 40]
    ]


  it "eats sub selects", ->
    tokens = lexer.tokenize("select * from (select * from my_table) t")
    tokens.should.eql [
      ["SELECT", "select", 1, 0]
      ["STAR", "*", 1, 7]
      ["FROM", "from", 1, 9]
      [ 'LEFT_PAREN', '(', 1, 14]
      [ 'SELECT', 'select', 1, 15]
      [ 'STAR', '*', 1, 22]
      [ 'FROM', 'from', 1, 24]
      [ 'LITERAL', 'my_table', 1, 29]
      [ 'RIGHT_PAREN', ')', 1, 37]
      ["LITERAL", "t", 1, 39]
      ["EOF", "", 1, 40]
    ]

  it "eats joins", ->
    tokens = lexer.tokenize("select * from a join b on a.id = b.id")
    tokens.should.eql [
      ["SELECT", "select", 1, 0]
      ["STAR", "*", 1, 7]
      ["FROM", "from", 1, 9]
      [ 'LITERAL', 'a', 1, 14]
      [ 'JOIN', 'join', 1, 16]
      [ 'LITERAL', 'b', 1, 21]
      [ 'ON', 'on', 1, 23]
      [ 'LITERAL', 'a', 1, 26]
      [ 'DOT', '.', 1, 27]
      [ 'LITERAL', 'id', 1, 28]
      [ 'OPERATOR', '=', 1, 31]
      [ 'LITERAL', 'b', 1, 33]
      [ 'DOT', '.', 1, 34]
      [ 'LITERAL', 'id', 1, 35]
      ["EOF", "", 1, 37]
    ]

  it "eats case when", ->
    tokens = lexer.tokenize("select case when foo = 'a' then a when foo = 'b' then b else c end from table")
    tokens.should.eql [
      ['SELECT', 'select', 1, 0]
      ['CASE', 'case', 1, 7]
      ['WHEN', 'when', 1, 12]
      ['LITERAL', 'foo', 1, 17]
      ['OPERATOR', '=', 1, 21]
      ['STRING', 'a', 1, 23]
      ['THEN', 'then', 1, 27]
      ['LITERAL', 'a', 1, 32]
      ['WHEN', 'when', 1, 34]
      ['LITERAL', 'foo', 1, 39]
      ['OPERATOR', '=', 1, 43]
      ['STRING', 'b', 1, 45]
      ['THEN', 'then', 1, 49]
      ['LITERAL', 'b', 1, 54]
      ['ELSE', 'else', 1, 56]
      ['LITERAL', 'c', 1, 61]
      ['END', 'end', 1, 63]
      ['FROM', "from", 1, 67]
      ['LITERAL', 'table', 1, 72]
      ['EOF', '', 1, 77]
    ]