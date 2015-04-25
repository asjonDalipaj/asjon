# Description:
#   interazioni tra asjon e github

module.exports = (robot) ->
  robot.router.post '/hubot/githubhook/:room', (req, res) ->
    res.send 200
    console.log req.body
    robot.send req.params.room, JSON.stringify req.body
    if req.body.ref is 'refs/head/master'
      s = 'Sono stato aggiornato!\n'
      cm = req.body.commits.map (c) ->
        [c.committer.username,c.message].join ' -> '
      commits = cm.join '\n'
      robot.send req.params.room, s+commits
