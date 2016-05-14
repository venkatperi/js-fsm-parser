# js-fsm
### Moore Finite State Machine (FSM)

[![Build Status](https://travis-ci.org/venkatperi/js-fsm.svg?branch=master)](https://travis-ci.org/venkatperi/js-fsm)


`js-fsm` is a simple javascript Moore Finite State Machine. A [Moore machine](https://en.wikipedia.org/wiki/Moore_machine) is a finite-state machine whose output values are determined solely by its current state.

To use `js-fsm`, define:
* the starting state,
* transitions (from state, to state, and inputs)
* outputs at each state.

Next, set your inputs and call `fsm.clock()`.

# Installation

Install with npm

```shell
npm install js-fsm
```

# Example
### Simple Vending Machine

A vending machine dispenses pieces of candy that cost 20 cents each. The machine accepts nickels and dimes only and does not give change. As soon as the amount deposited equals or exceeds 20 cents, the machine releases a piece of candy. The next coin deposited starts the process over again.

![](assets/vending-fsm.png)

Our state machine has states for the each possible deposited amount: 0 for zero cents deposited, 5 cents, 10 cents, 15 cents, 20 cents and 25 cents.


#### Defining the FSM
```
fsm = require( 'js-fsm' )
  initial : '0' # starting balance is zero
  transitions : [
    { from : [ '0', '20' ], to : '5', inputs : 'nickle' }
    { from : [ '0', '20' ], to : '10', inputs : 'dime' }
    { from : [ '5', '25' ], to : '10', inputs : 'nickle' }
    { from : [ '5', '25' ], to : '15', inputs : 'dime' }
    { from : '10', to : '15', inputs : 'nickle' }
    { from : '10', to : '20', inputs : 'dime' }
    { from : '15', to : '20', inputs : 'nickle' }
    { from : '15', to : '25', inputs : 'dime' }
  ]
  outputs :
    '^5,25' : [ 'light5' ]
    '^10' : [ 'light10' ]
    '^15' : [ 'light15' ]
    '^20, 25' : [ 'lightCandy' ]
```

#### Operating the vending machine

```coffeescript
# from the example

insert 'nickle'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'nickle'
```

Output

```
  coin   |  from   |   to    |    5    |   10    |   15    |  candy
 ------- + ------- + ------- + ------- + ------- + ------- + -------
 #nickle |    0    |    5    |    x    |         |         |
 ------- + ------- + ------- + ------- + ------- + ------- + -------
  #dime  |    5    |   15    |         |         |    x    |
 ------- + ------- + ------- + ------- + ------- + ------- + -------
  #dime  |   15    |   25    |    x    |         |         |    x
 ------- + ------- + ------- + ------- + ------- + ------- + -------
  #dime  |   25    |   15    |         |         |    x    |
 ------- + ------- + ------- + ------- + ------- + ------- + -------
  #dime  |   15    |   25    |    x    |         |         |    x
 ------- + ------- + ------- + ------- + ------- + ------- + -------
  #dime  |   25    |   15    |         |         |    x    |
 ------- + ------- + ------- + ------- + ------- + ------- + -------
 #nickle |   15    |   20    |         |         |         |    x
 ------- + ------- + ------- + ------- + ------- + ------- + -------
```

# API

## Create FSM

### fsm(options)

`options` is an `{Object}`

* **initial** is a `{String}` with the initial state name.

* **transitions** is an `{Array}` of `{Object}`s that specify the destination state and necessary inputs for each transition

  * **from** `{String}` is the current state
  * **to** `{String}` is the destination of the transition
  * **inputs** is an `{Array}` of signal names and their required state. A transition is possible only if all inputs are true. A `signal` prefixed with a `!` is negated and so is true if it is low (false) and vice-versa.
  * **description** is an optional `{String}` which is returned in `leave` and `enter` callbacks.

```coffeescript
# This transition will occur only when start is true and cancelled is false
{ from: 'initial', to: 'type', inputs: ['start', '!cancelled']
```

* **outputs** `{Object}` specifies which signals  are to be set (and their value) depending on the current state.

```coffeescript
# signal 'candy' will go high only in states 20 and 25 and is low everywhere else
# 'FIVE' will go high only in state 25 and is low everywhere else
# Prefixing with an exclamation will set the outputs for all states other than the
# specified ones

outputs :
  '20, 25' : [ 'candy' ]
  '!20, 25' : [ '!candy' ]
  '0, 5, 10, 15, 20' : [ '!FIVE' ]
  '25' : [ 'FIVE' ]
```

#### Inverting States
Prefixing with an exclamation `!` will set the outputs for all states other than the specified ones.
```
   # Output 'candy' is set reset in states other than 20 and 25
   '!20, 25': ['!candy']
```

#### If-and-only-if Output
Prefixing with a caret `^` sets the state/output combination as `if-and-only-if`
```
   # Output 'candy' is set in states 20 and 25, and reset everywhere else
   '^20, 25': ['candy']
```

## Methods

### fsm.signal([value])

Gets or sets the value of the named signal (signal must be replaced with the appropriate name above).

```coffeescript
#set signal nickle to true and dime to false
fsm
.nickle true
.dime false
```

### fsm.clock()

Instructs the FSM to attempt a transition based on the current input values. If no transition is possible, the fsm will emit a `noop` event. 

```coffeescript
# sets input values and and transitions (if possible)
fsm
.dime false
.nickle true
.clock()
```

### fsm.current()
The current state's name

## Events 

### on('noop', cb())

`fsm.clock()` resulted in no state change.

### on('state', cb(state, from, desc))

Fired when the FSM transitions to a state. The callback **cb** receives the state names **state**, **from** and a string description of why the transition occured.

### on('error', cb(Error))
Fired if an error occurs. e.g. to many transitions from a state.

### on('changed:signal', cb(new, old))
Fired when a signal value changes. Signal values can change either by the user by calling fsm.signal(value), or as a result of entering a new state.

## Order of Events

On a state change, events are emitted in the following order:
* `changed:signal` for any changed output/signals
* `state`


