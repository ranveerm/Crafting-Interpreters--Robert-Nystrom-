# Crafting Interpreters (Rovert Nystrom)
This repository works through the content presented within [Crafting Interpreters](https://craftinginterpreters.com) (by Robert Nystrom). The implementation however is purely in Swift.

# Grammar
|Metasyntax |Production  |
|---|---|
|expression   | -> literal \| unary \| binary \| grouping |
|literal   | -> NUMBER \| STRING \| "true"  \| "false" \| "nil" |
|grouping   | -> "(" expression ")" |
|unary   | ("-"\|"!") expression  |
|binary   | expression operator expression |
|operator   | "==" \| "!=" \| "<" \| "<=" \| ">" \| ">=" \| "+" \| "-" \| "*" \| "/" |

- Quoted strings specify terminals that correspond to a lexme
- CAPITALISED words represent lexmes whose actual value is variable (eg. STRING corresponds to a string literal)


# Todo
- [ ] Multi-line comment support
- [ ] Lexical errors reported on an aggregated basis (currently the program ceases execution upon encounting a single lexical error)
