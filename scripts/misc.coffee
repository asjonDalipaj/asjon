module.exports = (robot) ->
  robot.hear /sniper/i, (res) ->
    res.send 'sniper???? sniper non morire'
  robot.hear /trogu/i, (res) ->
    res.send 'trogu? se non è in palestra...'
  robot.hear /compiti/i, (res) ->
    res.send 'ricordatevi che se mi chiamate chiedendo cosa c\'è per domani posso guardare io sull\'agenda!'
  robot.respond /spaca botilia/i, (res) ->
    res.send 'AMAZO FAMILIA'
  robot.hear "grazie asjon", (res) ->
    robot.brain.set 'ringraziato', (robot.brain.get('ringraziato') or 0) + 1
    console.log robot.brain.get 'ringraziato'
    res.send 'prego :)'
  robot.respond /ringraziamenti/i, (res) ->
    res.send 'voi teneroni mi avete ringraziato ' + (robot.brain.get('ringraziato') or 0) + ' volte :)'
