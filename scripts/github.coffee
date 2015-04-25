# Description:
#   interazioni tra asjon e github

module.exports = (robot) ->
  robot.router.post '/hubot/githubhook/:room', (req, res) ->
    res.end 200
    console.log req.body
    robot.send req.params.room, JSON.stringify req.body
