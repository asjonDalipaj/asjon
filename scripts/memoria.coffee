module.exports = (robot) ->
  robot.respond /ricorda(?:ti)? (?:che )?(.+) ([=è]|sono) (.+)/i, (res) ->
    mem = robot.brain.get('memoria') or {}
    name = res.match[1].toLowerCase(); definition = res.match[3]
    r = if res.match[2] is 'sono' then 'fossero' else 'fosse'
    if mem[name]?
      res.send 'pensavo che '+name+' '+r+' '+mem[name]+'. Mi ricorderò che invece è '+definition
    else
      res.send 'non sapevo che '+name+' '+r+' '+definition+'. Me lo ricorderò'
    mem[name] = definition
    robot.brain.set 'memoria', mem
  robot.respond /dimentica(?:ti)? (.+)/i, (res) ->
    mem = robot.brain.get('memoria') or {}
    m = res.match[1].toLowerCase()
    if mem[m]?
      res.send 'cancellazione neuronale in corso...'
      delete mem[m]
      robot.brain.set 'memoria', mem # necessary?
    else res.send 'non so cosa sia'
  robot.respond /(?:che )?((?:(?:(?:(?:cos|qual)\'è)|chi (?:sono|è)?))|(?:quali|cosa) sono) (.+)(?:\?)?/i, (res) ->
    mem = robot.brain.get('memoria') or {}
    arg = (res.match[2] or res.match[1]).toLowerCase()
    verbo = res.match[1].toLowerCase().split(/[' ]/i)
    verbo = verbo[verbo.length-1]
    if mem[arg]
      res.send arg+' '+verbo+' '+mem[arg]
    else res.send 'boh'
  robot.respond /memoria/i, (res) ->
    m = JSON.stringify robot.brain.get 'memoria'
    if m isnt 'null'
      res.send m
    else res.send 'non so niente...'
