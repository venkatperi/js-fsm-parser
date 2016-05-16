should = require("should")
assert = require("assert")
parser = require '../index'
path = require 'path'
fs = require 'fs'
_ = require 'lodash'

src = ( file ) ->
  fs.readFileSync path.join(__dirname,
    "fixtures/#{file}.src"), encoding : "utf8"


describe "AST", ->

  fsm = undefined
  before ->
    fsm = parser src "vending"
    console.log fsm.toString()

  it "Top level item is 'FSM'", ( done ) ->
    fsm.type.should.equal "FSM"
    done()

  it "findByType", ( done ) ->
    nodes = {}
    for type in [ 'state', 'input', 'output' ]
      nodes[ "#{type}s" ] = fsm.findUniqByType _.capitalize(type)

    nodes.states.length.should.equal 7
    nodes.inputs.length.should.equal 3
    nodes.outputs.length.should.equal 6
    done()

