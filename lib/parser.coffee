{parser} = require './grammar/fsm'
Node = require './Node'

parse = ( src ) ->
  ast = parser.parse src
  base = new Node ast
  return base

parse.cache = Node.cache
  
module.exports = parse

