module.exports = (robot) ->
  robot.respond /ricorda(?:ti)? (?:che )?(.+) [=è] (.+)/i, (res) ->
    mem = robot.brain.get('memoria') or {}
    name = res.match[1]; definition = res.match[2]
    if mem[name]?
      res.send 'pensavo che '+name+' fosse '+mem[name]+'. Mi ricorderò che invece è '+definition
    else
      res.send 'non sapevo che '+name+' fosse '+definition+'. Me lo ricorderò'
    mem[name] = definition
    robot.brain.set 'memoria', mem
  robot.respond /dimentica(?:ti)? (.+)/i, (res) ->
    mem = robot.brain.get('memoria') or {}
    if mem[res.match[1]]?
      res.send 'cancellazione neuronale in corso...'
      delete mem[res.match[1]]
      robot.brain.set 'memoria', mem # necessary?
    else res.send 'non so cosa sia'
  robot.respond /(?:che )?cos(?:\')?è (.+)/i, (res) ->
    mem = robot.brain.get('memoria') or {}
    if mem[res.match[1]]
      res.send res.match[1]+' è '+mem[res.match[1]]
    else res.send 'boh'
  robot.respond /memoria/i, (res) ->
    m = JSON.stringify robot.brain.get 'memoria'
    if m isnt 'null'
      res.send m
    else res.send 'non so niente...'
