_ = require 'lodash'
guavaCache = require 'guava-cache'

name = ( x ) -> x.id.name

class NodeVisitor
  constructor : ( @node, @depth ) ->
  visit : ( visitor ) =>
    visitor.call @, @node
    @

_visit = ( @node, @depth, visitor ) ->
  new NodeVisitor @node, @depth
  .visit visitor

nextId = 1
cache = guavaCache()

class Node
  constructor : ( node, @parent ) ->
    @id = nextId++
    @type = node.type
    @children = node.children or []
    for attr in @children ? [] when node[ attr ]
      val = node[ attr ]
      if Array.isArray val
        @[ attr ] = (new Node child, @ for child in val )
      else if val.type
        @[ attr ] = new Node val, @
      else
        @[ attr ] = val

  cache: -> cache
    
  scalars : =>
    items = []
    for attr in @children when @[ attr ]
      val = @[ attr ]
      items.push attr if !(_.isArray(val) or val instanceof Node)
    items

  walk : ( visitor, depth = 0 ) =>
    _visit(@, depth, visitor)
    for attr in @children when @[ attr ]
      val = @[ attr ]
      if val instanceof Node
        val.walk(visitor, depth + 1)
      else if Array.isArray val
        for child in val when child instanceof Node
          child.walk(visitor, depth + 1)

  _toString : =>
    str = ("#{attr}: #{@[ attr ]}" for attr in @scalars()).join ', '
    prefix = [ "#{@type} (", @children.join(','), ')' ].join ('')

    [ "#{prefix}", str ].join (' ')

  toString : () =>
    lines = []
    @walk ( node ) ->
      lines.push _.repeat('  ', @depth) + node._toString()
    lines.join '\n'

  filter : ( fn ) =>
    items = []
    @walk ( node ) ->
      items.push node if fn node
    items

  findByType : ( type ) =>
    f = => @filter ( node ) -> node.type is type
    cache.get "#{@id}:findByType:#{type}", f

  findUniqByType : ( type, criterion = name ) =>
    _.uniqBy @findByType(type), criterion

module.exports = Node
