module.exports = flatten = ( array ) ->
  flattened = []
  for element in array
    if '[object Array]' is Object::toString.call element
      flattened = flattened.concat flatten element
    else
      flattened.push element
      
  flattened