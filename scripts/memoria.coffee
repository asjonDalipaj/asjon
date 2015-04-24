moment = require 'moment'
moment.locale 'it'

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
    nonso = ['non so cosa sia','BZBZ 404-NOT-FOUND','non mi fa ne caldo ne freddo','se sapessi cos\'è magari']
    if mem[m]?
      res.send 'cancellazione neuronale in corso...'
      delete mem[m]
      robot.brain.set 'memoria', mem # necessary?
    else res.send res.random nonso

  robot.respond /memory-dump/i, (res) ->
    res.send JSON.stringify robot.brain.get('memoria')

  robot.respond /(?:che )?(?:(?:(?:(?:(cos|qual|quand)\'è)|(?:chi (sono|è)?)))|(?:quali|cosa) sono) ([\w- ]+)(?:\?)?/i, (res) ->
    query = undefined
    # Estrazione query (quand,cos,qual,chi...)
    if res.match[2] then query = res.match[2] or res.match[1]
    else if res.match[3] and res.match[1] then query = res.match[1]
    # Estrazione argomento della query
    arg = (res.match[3] or res.match[2] or res.match[1]).toLowerCase()
    # Controllo data
    if moment(arg,'YYYY-MM-DD').isValid() and (query is 'quand' or query is 'cos')
      # chiesto una data
      data = moment(arg,'[il] YYYY-MM-DD')
      res.send arg+' è '+data.format('dddd Do MMMM YYYY')+' ovvero '+data.fromNow()
    else
      # chiesto qualcosa che non è una data
      mem = robot.brain.get('memoria') or {}
      verbo = if query? then 'è' else 'sono'
      if mem[arg]
        # controllo se è salvata una data nell'argomento chiesto
        data = moment(mem[arg],'[il] YYYY-MM-DD')
        if data.isValid()
          # nella memoria era salvata una data
          res.send arg+' è '+data.format('dddd Do MMMM YYYY')+' ovvero '+data.fromNow()
        else res.send arg+' '+verbo+' '+mem[arg]
      else res.send res.random ['boh','mistero','se qualcuno me lo spiega magari','BZBZ 404-NOT-FOUND']

  robot.respond /(?:mostrami la tua )?memoria|a cosa stai pensando(?:\?)?/i, (res) ->
    m = robot.brain.get 'memoria'
    if m isnt null
      r = ['ho studiato', 'ho imparato', 'ho appreso', 'sono venuto a conoscenza di']
      res.send 'nel corso della mia vita '+res.random(r)+' '+(i for i of m).join(', ')
    else res.send res.random ['non so niente...', 'ignoranza proprio']
