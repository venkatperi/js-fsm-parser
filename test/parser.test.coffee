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

  it "Top level item is 'FSM'", ( done ) ->
    fsm.type.should.equal "FSM"
    done()

  it "findByType", ( done ) ->
    states = _.uniq (s.id.name for s in fsm.findByType 'State')
    inputs = _.uniq (s.id.name for s in fsm.findByType 'Input')
    outputs = _.uniq (s.id.name for s in fsm.findByType 'Output')
    states.length.should.equal 7
    inputs.length.should.equal 3
    outputs.length.should.equal 6
    done()

