module.exports = (robot) ->
  grazie = (res) ->
    robot.brain.set 'ringraziato', (robot.brain.get('ringraziato') or 0) + 1
    res.send res.random ['prego :)', "non c'è di che"]
  robot.hear /sniper/i, (res) ->
    res.send 'sniper???? sniper non morire'
  robot.hear /trogu/i, (res) ->
    res.send 'trogu? se non è in palestra...'
  robot.hear /compiti/i, (res) ->
    res.send 'ricordatevi che se mi chiamate chiedendo cosa c\'è per domani posso guardare io sull\'agenda!'
  robot.respond /spaca botilia/i, (res) ->
    res.send 'AMAZO FAMILIA'
  robot.hear /grazie asjon/i, grazie
  robot.respond /grazie/i, grazie
  robot.respond /ringraziamenti/i, (res) ->
    res.send 'voi teneroni mi avete ringraziato ' + (robot.brain.get('ringraziato') or 0) + ' volte :)'
  robot.respond /saluta (.+)/i, (res) ->
    res.send 'ciao ' + res.match[1]
  robot.respond /dove sei/i, (res) ->
    robot.http('http://canihazip.com/s')
      .get() (err, r, body) ->
        res.send 'dovrei essere a ' + body
