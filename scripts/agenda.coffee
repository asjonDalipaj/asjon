Nightmare = require 'nightmare'
cheerio = require 'cheerio'
moment = require 'moment'

downloadAgenda = (day, cb) ->
  cbCalled = no
  htmlData = ""
  loadHtml = -> document.body.innerHTML
  saveHtml = (data) -> htmlData = data
  dayHasEvents = (b) ->
    unless b
      cbCalled = yes
      cb []
  console.log Nightmare
  ###
  .exists('a[href="?d='+day+'"]',dayHasEvents)
  .click('a[href="/agenda/"]').wait()
  .click('a[href="?d='+day+'"]').wait()
  ###
  n = new Nightmare()
    .goto('https://galilei-cr-sito.registroelettronico.com/login/')
    .type('#username',process.env.REGISTRO_USERNAME)
    .type('#password',process.env.REGISTRO_PASSWORD)
    .click('#btnLogin').wait()
  if process.env.REGISTRO_ID_STUDENTE
    n.goto('https://galilei-cr-sito.registroelettronico.com/select-student/'+process.env.REGISTRO_ID_STUDENTE+'/')
  n.goto('https://galilei-cr-sito.registroelettronico.com/agenda/?d='+day)
   .evaluate(loadHtml, saveHtml)
  n.run (err,nightmare) ->
    if err then console.log err
    if !cbCalled and htmlData.length > 0
      rowExtractor = ->
        if $('td',this).get(1)?
          $($('td',this).get(1)).text().trim()
        else ""
      $ = cheerio.load htmlData
      tab = $('.result_table tr').map(rowExtractor).get()
      tab.splice 0, 2
      cb tab

cosaCePerIl = (day,res) ->
  res.send 'aspetta che guardo l\'agenda per il '+day
  downloadAgenda day, (data) ->
    if data.length is 0
      res.send "non c'è niente per doma :)"
    else
      res.send "ecco cosa c'è per doma: "+data.join('; ')

module.exports = (robot) ->
  robot.hear "cosa c'è per domani?", (res) ->
    cosaCePerIl moment().add(1, 'days').format('YYYY-MM-DD'), res
