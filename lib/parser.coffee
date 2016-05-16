{parser} = require './grammar/fsm'
Node = require './Node'

parse = ( src ) ->
  ast = parser.parse src
  #console.log JSON.stringify ast, null, 2
  base = new Node ast
  return base
  
module.exports = parse

