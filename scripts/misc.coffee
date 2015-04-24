module.exports = (robot) ->
  # Ringraziamenti
  ringr = ['prego :)', "non c'è di che", "faccio solo il mio lavoro", "no problemo amigo", "non fate complimenti ;)"]
  grazie = (res) ->
    robot.brain.set 'ringraziato', (robot.brain.get('ringraziato') or 0) + 1
    res.send res.random ringr
  robot.hear /(?:grazie|bravo) (?:asjon|assa|assioni)/i, grazie
  robot.respond /grazie/i, grazie
  robot.respond /ringraziamenti/i, (res) ->
    res.send 'voi teneroni mi avete ringraziato ' + (robot.brain.get('ringraziato') or 0) + ' volte :)'
  # Richiami
  robot.respond /sei (?:(?:proprio|davvero|veramente) )?(.+)/i, (res) ->
    nomi = robot.brain.get('nomi') or {}
    nomi[res.match[1]] ?= 0
    nomi[res.match[1]] += 1
    robot.brain.set 'nomi', nomi
  robot.respond /come ti hanno chiamato/i, (res) ->
    a = robot.brain.get('nomi') or {}
    l = []
    for i of a
      l.push a[i]+' volt'+(if a[i] is 1 then 'a' else 'e')+' '+i
    res.send 'mi hanno chiamato '+l.join(', ')
  # Altro
  robot.hear /compiti/i, (res) ->
    res.send 'ricordatevi che se mi chiamate chiedendo cosa c\'è per domani posso guardare io sull\'agenda!'
  robot.respond /spaca botilia/i, (res) ->
    res.send 'AMAZO FAMILIA'
  robot.respond /saluta (.+)/i, (res) ->
    res.send 'ciao ' + res.match[1]
  robot.respond /dove sei/i, (res) ->
    robot.http('http://canihazip.com/s')
      .get() (err, r, body) ->
        res.send 'dovrei essere a ' + body
  robot.respond /con chi stai parlando/i, (res) ->
    if res.message.user.name is res.message.room
      res.send 'sto parlando con te, '+res.message.user.name
    else
      res.send 'sto parlando in '+res.message.room+', '+res.message.user.name
  robot.respond /ti amo/i, (res) ->
    res.send 'anche io ti amo '+(res.message.user.name+' ' or '')+'<3'
  robot.respond /secret-kill-code/i, (res) -> process.exit 0
