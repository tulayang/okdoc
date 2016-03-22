# [语法](http://nim-lang.org/docs/manual.html#syntax)

在这里，我们汇总了 Nim 语言的标准语法。

Nim 语言允许用户定义操作符，二元操作符有 11 个优先级。

## 左联合和右联合

所有的二元操作符，以 `^` 起始的操作符是右联合的，其他操作符是左联合的。

```nim
proc `^/`(x, y: float): float =
    # 右联合除法操作符
    result = x / y
echo 12 ^/ 4 ^/ 8 # 24.0 (4 / 8 = 0.5, then
                  #      12 / 0.5 = 24.0)
echo 12  / 4  / 8 # 0.375 (12 / 4 = 3.0, then
                  #         3 / 8 = 0.375)
``` 

## 优先级

一元操作符总是比二元操作符有更高的绑定优先级： `$a + b` 被解析为 `($a) + b` 而不是 `$(a + b)` 。一元操作符 `@` 拥有更高的绑定优先级： `@x.abc` 被解析为 `(@x).abc`，而 `$x.abc` 被解析为 `$(x.abc)` 。

二元操作符的优先级，由以下规则决定：

1. 箭头操作符 `->` `~>` `=>`，是所有操作符中优先级最低的。 
2. 以 `=` 结尾的操作符，并且第一个字符不是 `<` `>` `!` `=` `~` `?`，属于赋值操作符，拥有次低优先级。
3. 其它优先级，由第一个字符决定。
   
优先级|操作符|第一个字符|节点符号
-|-|-|-
10 (最高)|    |`$` `^` |OP10
9| `*` `/` `div` `mod` `shl` `shr` `%` |`*` `%` `\` `/` |OP9
8| `+` `-` |`+` `-` `~` `｜` |OP8
7| `&`| `&` |OP7
6| `..`|  `.` |OP6
5| `==` `<=` `<` `>=` `>` `!=` `in` `notin` `is` `isnot` `not` `of`|  `=` `<` `>` `!` |OP5
4| `and`|   |OP4
3| `or` `xor`|    |OP3
2|   |`@` `:` `?` |OP2
1| 赋值操作符 (类似 `+=`, `*=`)|   |OP1
0 (最低)|  箭头操作符 (类似 `->`, `=>`)|   |OP0

## 语法


```?
module = stmt ^* (';' / IND{=})
comma = ',' COMMENT?
semicolon = ';' COMMENT?
colon = ':' COMMENT?
colcom = ':' COMMENT?
operator =  OP0 | OP1 | OP2 | OP3 | OP4 | OP5 | OP6 | OP7 | OP8 | OP9
         | 'or' | 'xor' | 'and'
         | 'is' | 'isnot' | 'in' | 'notin' | 'of'
         | 'div' | 'mod' | 'shl' | 'shr' | 'not' | 'static' | '..'
prefixOperator = operator
optInd = COMMENT?
optPar = (IND{>} | IND{=})?
simpleExpr = arrowExpr (OP0 optInd arrowExpr)*
arrowExpr = assignExpr (OP1 optInd assignExpr)*
assignExpr = orExpr (OP2 optInd orExpr)*
orExpr = andExpr (OP3 optInd andExpr)*
andExpr = cmpExpr (OP4 optInd cmpExpr)*
cmpExpr = sliceExpr (OP5 optInd sliceExpr)*
sliceExpr = ampExpr (OP6 optInd ampExpr)*
ampExpr = plusExpr (OP7 optInd plusExpr)*
plusExpr = mulExpr (OP8 optInd mulExpr)*
mulExpr = dollarExpr (OP9 optInd dollarExpr)*
dollarExpr = primary (OP10 optInd primary)*
symbol = '`' (KEYW|IDENT|literal|(operator|'('|')'|'['|']'|'{'|'}'|'=')+)+ '`'
       | IDENT | 'addr' | 'type'
indexExpr = expr
indexExprList = indexExpr ^+ comma
exprColonEqExpr = expr (':'|'=' expr)?
exprList = expr ^+ comma
dotExpr = expr '.' optInd symbol
qualifiedIdent = symbol ('.' optInd symbol)?
exprColonEqExprList = exprColonEqExpr (comma exprColonEqExpr)* (comma)?
setOrTableConstr = '{' ((exprColonEqExpr comma)* | ':' ) '}'
castExpr = 'cast' '[' optInd typeDesc optPar ']' '(' optInd expr optPar ')'
parKeyw = 'discard' | 'include' | 'if' | 'while' | 'case' | 'try'
        | 'finally' | 'except' | 'for' | 'block' | 'const' | 'let'
        | 'when' | 'var' | 'mixin'
par = '(' optInd (&parKeyw complexOrSimpleStmt ^+ ';'
                 | simpleExpr ('=' expr (';' complexOrSimpleStmt ^+ ';' )? )?
                            | (':' expr)? (',' (exprColonEqExpr comma?)*)?  )?
        optPar ')'
literal = | INT_LIT | INT8_LIT | INT16_LIT | INT32_LIT | INT64_LIT
          | UINT_LIT | UINT8_LIT | UINT16_LIT | UINT32_LIT | UINT64_LIT
          | FLOAT_LIT | FLOAT32_LIT | FLOAT64_LIT
          | STR_LIT | RSTR_LIT | TRIPLESTR_LIT
          | CHAR_LIT
          | NIL
generalizedLit = GENERALIZED_STR_LIT | GENERALIZED_TRIPLESTR_LIT
identOrLiteral = generalizedLit | symbol | literal
               | par | arrayConstr | setOrTableConstr
               | castExpr
tupleConstr = '(' optInd (exprColonEqExpr comma?)* optPar ')'
arrayConstr = '[' optInd (exprColonEqExpr comma?)* optPar ']'
primarySuffix = '(' (exprColonEqExpr comma?)* ')' doBlocks?
      | doBlocks
      | '.' optInd symbol generalizedLit?
      | '[' optInd indexExprList optPar ']'
      | '{' optInd indexExprList optPar '}'
      | &( '`'|IDENT|literal|'cast'|'addr'|'type') expr # command syntax
condExpr = expr colcom expr optInd
        ('elif' expr colcom expr optInd)*
         'else' colcom expr
ifExpr = 'if' condExpr
whenExpr = 'when' condExpr
pragma = '{.' optInd (exprColonExpr comma?)* optPar ('.}' | '}')
identVis = symbol opr?  # postfix position
identWithPragma = identVis pragma?
declColonEquals = identWithPragma (comma identWithPragma)* comma?
                  (':' optInd typeDesc)? ('=' optInd expr)?
identColonEquals = ident (comma ident)* comma?
     (':' optInd typeDesc)? ('=' optInd expr)?)
inlTupleDecl = 'tuple'
    [' optInd  (identColonEquals (comma/semicolon)?)*  optPar ']'
extTupleDecl = 'tuple'
    COMMENT? (IND{>} identColonEquals (IND{=} identColonEquals)*)?
tupleClass = 'tuple'
paramList = '(' declColonEquals ^* (comma/semicolon) ')'
paramListArrow = paramList? ('->' optInd typeDesc)?
paramListColon = paramList? (':' optInd typeDesc)?
doBlock = 'do' paramListArrow pragmas? colcom stmt
doBlocks = doBlock ^* IND{=}
procExpr = 'proc' paramListColon pragmas? ('=' COMMENT? stmt)?
distinct = 'distinct' optInd typeDesc
expr = (ifExpr
      | whenExpr
      | caseExpr
      | tryExpr)
      / simpleExpr
typeKeyw = 'var' | 'ref' | 'ptr' | 'shared' | 'tuple'
         | 'proc' | 'iterator' | 'distinct' | 'object' | 'enum'
primary = typeKeyw typeDescK
        /  prefixOperator* identOrLiteral primarySuffix*
        / 'static' primary
        / 'bind' primary
typeDesc = simpleExpr
typeDefAux = simpleExpr
           | 'concept' typeClass
macroColon = ':' stmt? ( IND{=} 'of' exprList ':' stmt
                       | IND{=} 'elif' expr ':' stmt
                       | IND{=} 'except' exprList ':' stmt
                       | IND{=} 'else' ':' stmt )*
exprStmt = simpleExpr
         (( '=' optInd expr )
         / ( expr ^+ comma
             doBlocks
              / macroColon
           ))?
importStmt = 'import' optInd expr
              ((comma expr)*
              / 'except' optInd (expr ^+ comma))
includeStmt = 'include' optInd expr ^+ comma
fromStmt = 'from' moduleName 'import' optInd expr (comma expr)*
returnStmt = 'return' optInd expr?
raiseStmt = 'raise' optInd expr?
yieldStmt = 'yield' optInd expr?
discardStmt = 'discard' optInd expr?
breakStmt = 'break' optInd expr?
continueStmt = 'break' optInd expr?
condStmt = expr colcom stmt COMMENT?
           (IND{=} 'elif' expr colcom stmt)*
           (IND{=} 'else' colcom stmt)?
ifStmt = 'if' condStmt
whenStmt = 'when' condStmt
whileStmt = 'while' expr colcom stmt
ofBranch = 'of' exprList colcom stmt
ofBranches = ofBranch (IND{=} ofBranch)*
                      (IND{=} 'elif' expr colcom stmt)*
                      (IND{=} 'else' colcom stmt)?
caseStmt = 'case' expr ':'? COMMENT?
            (IND{>} ofBranches DED
            | IND{=} ofBranches)
tryStmt = 'try' colcom stmt &(IND{=}? 'except'|'finally')
           (IND{=}? 'except' exprList colcom stmt)*
           (IND{=}? 'finally' colcom stmt)?
tryExpr = 'try' colcom stmt &(optInd 'except'|'finally')
           (optInd 'except' exprList colcom stmt)*
           (optInd 'finally' colcom stmt)?
exceptBlock = 'except' colcom stmt
forStmt = 'for' (identWithPragma ^+ comma) 'in' expr colcom stmt
blockStmt = 'block' symbol? colcom stmt
staticStmt = 'static' colcom stmt
deferStmt = 'defer' colcom stmt
asmStmt = 'asm' pragma? (STR_LIT | RSTR_LIT | TRIPLE_STR_LIT)
genericParam = symbol (comma symbol)* (colon expr)? ('=' optInd expr)?
genericParamList = '[' optInd
  genericParam ^* (comma/semicolon) optPar ']'
pattern = '{' stmt '}'
indAndComment = (IND{>} COMMENT)? | COMMENT?
routine = optInd identVis pattern? genericParamList?
  paramListColon pragma? ('=' COMMENT? stmt)? indAndComment
commentStmt = COMMENT
section(p) = COMMENT? p / (IND{>} (p / COMMENT)^+IND{=} DED)
constant = identWithPragma (colon typedesc)? '=' optInd expr indAndComment
enum = 'enum' optInd (symbol optInd ('=' optInd expr COMMENT?)? comma?)+
objectWhen = 'when' expr colcom objectPart COMMENT?
            ('elif' expr colcom objectPart COMMENT?)*
            ('else' colcom objectPart COMMENT?)?
objectBranch = 'of' exprList colcom objectPart
objectBranches = objectBranch (IND{=} objectBranch)*
                      (IND{=} 'elif' expr colcom objectPart)*
                      (IND{=} 'else' colcom objectPart)?
objectCase = 'case' identWithPragma ':' typeDesc ':'? COMMENT?
            (IND{>} objectBranches DED
            | IND{=} objectBranches)
objectPart = IND{>} objectPart^+IND{=} DED
           / objectWhen / objectCase / 'nil' / 'discard' / declColonEquals
object = 'object' pragma? ('of' typeDesc)? COMMENT? objectPart
typeClassParam = ('var')? symbol
typeClass = typeClassParam ^* ',' (pragma)? ('of' typeDesc ^* ',')?
              &IND{>} stmt
typeDef = identWithPragma genericParamList? '=' optInd typeDefAux
            indAndComment?
varTuple = '(' optInd identWithPragma ^+ comma optPar ')' '=' optInd expr
variable = (varTuple / identColonEquals) indAndComment
bindStmt = 'bind' optInd qualifiedIdent ^+ comma
mixinStmt = 'mixin' optInd qualifiedIdent ^+ comma
pragmaStmt = pragma (':' COMMENT? stmt)?
simpleStmt = ((returnStmt | raiseStmt | yieldStmt | discardStmt | breakStmt
           | continueStmt | pragmaStmt | importStmt | exportStmt | fromStmt
           | includeStmt | commentStmt) / exprStmt) COMMENT?
complexOrSimpleStmt = (ifStmt | whenStmt | whileStmt
                    | tryStmt | forStmt
                    | blockStmt | staticStmt | deferStmt | asmStmt
                    | 'proc' routine
                    | 'method' routine
                    | 'iterator' routine
                    | 'macro' routine
                    | 'template' routine
                    | 'converter' routine
                    | 'type' section(typeDef)
                    | 'const' section(constant)
                    | ('let' | 'var') section(variable)
                    | bindStmt | mixinStmt)
                    / simpleStmt
stmt = (IND{>} complexOrSimpleStmt^+(IND{=} / ';') DED)
     / simpleStmt ^+ ';'
```