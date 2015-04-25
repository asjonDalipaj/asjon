# Description:
#   interazioni tra asjon e github

module.exports = (robot) ->
  robot.router.post '/hubot/githubhook/:room/:name', (req, res) ->
    res.send 200
    if !process.env.GITHUB_API_SECRET
      console.log 'non sono configurato per GITHUB API WEBHOOKS!'
      return
    else if "sha1="+process.env.GITHUB_API_SECRET isnt req.headers["x-hub-signature"]
      console.log 'MALFORMED GITHUB API SECRET: was',
        req.headers["x-hub-signature"], 'but expected', "sha1="+process.env.GITHUB_API_SECRET
      return
    dest = name: req.params.name, room: req.params.room
    if req.body.ref is 'refs/head/master'
      s = 'Sono stato aggiornato!\n'
      cm = req.body.commits.map (c) ->
        [c.committer.username,c.message].join ' -> '
      commits = cm.join '\n'
      robot.send dest, s+commits
