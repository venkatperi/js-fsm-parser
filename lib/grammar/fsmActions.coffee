child = ( node, child ) ->
  node.items.splice 0, 0, child
  node

option = ( node, name, value ) ->
  node[ name ] = value
  node.children.push name
  node

node = ( type, children ) ->
  names = []
  obj = { type : type, children : [] }
  for own name, value of children
    obj.children.push name
    obj[ name ] = value
  obj

list = ( item ) ->
  node "#{item.type}List", items : [ item ]

module.exports =
  node : node
  list : list
  option : option
  child : child
