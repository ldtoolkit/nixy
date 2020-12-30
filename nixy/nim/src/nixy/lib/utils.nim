template suppress*(body: untyped) =
  try:
    body
  except:
    discard
