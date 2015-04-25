# Description:
#   interazioni tra asjon e github
#
# Requires:
#   "github": "0.2.4"
#
# Commands:
#   asjon mostra le issue - mostra le issue aperte su fazo96/asjon
#
# Author:
#   Enrico Fasoli (fazo96)

GitHubAPI = require 'github'
github = new GitHubAPI version: '3.0.0'

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
    dest = name: req.params.name, room: req.params.room.replace(':','#')
    if req.body.ref is 'refs/heads/master'
      s = 'Sono stato aggiornato!\n'
      cm = req.body.commits.map (c) ->
        [c.committer.username,c.message].join ' -> '
      commits = cm.join '\n'
      robot.send dest, s+commits
    if process.env.AUTO_KILL_ON_UPDATE
      setTimeout 1000, ->
        console.log 'DYING NOW AS REQUESTED!'
        process.exit 0
  
  robot.respond /(?:(?:mostra(?:mi)?|fammi vedere) )(?:le )?issue(?:s)?/i, (res) ->
    msg = state: 'open', user: 'fazo96', repo: 'asjon', sort: 'updated'
    res.send 'controllo issues...'
    github.issues.repoIssues msg, (err,data) ->
      if err then return res.send err
      r = data.map (i) ->
        labels = i.labels.map((x) -> x.name).join ', '
        if labels is '' then labels = 'nessuno'
        ["#"+i.number,i.title,"By: "+i.user.login,'Tags: '+labels].join(' | ')
      res.send r.join '\n'
