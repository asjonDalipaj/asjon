module.exports = (robot) ->
  robot.hear /sniper/i, (res) ->
    res.send 'sniper???? sniper non morire'
  robot.hear /trogu/i, (res) ->
    res.send 'trogu? se non è in palestra...'
  robot.hear /compiti/i, (res) ->
    res.send 'ricordatevi che se mi chiamate chiedendo cosa c\'è per domani posso guardare io sull\'agenda!'
