# Description:
#   si collega al sito della scuola e legge le circolari
#
# Dependencies:
#   "cheerio": "0.19.0"
# 
# Configuration:
#   None
#
# Commands:
#   hubot mostrami le circolari - stampa la lista delle ultime circolari
#
# Author:
#   Enrico Fasoli (fazo96)
#

cheerio = require('cheerio')

parseHtml = (htmlData,done) ->
  $ = cheerio.load htmlData
  tab = $('tr').map (i) ->
    # console.log($('td',this).html())
    # console.log($(this,'td').length)
    link = ""; destinatario = ""
    l = $('td',this).map (j) ->
       # console.log($(this).html())
       if $('a',this).get(0)?
         #console.log($('a',this).get(0))
         if $('a',this).get(0).attribs?.href?
           link = 'http://galileicrema.it' + $('a',this).get(0).attribs.href
       item = $(this).text().trim()
       # console.log(i,j,item)
       # console.log(item.length)
       if(j == 5)
         destinatario = item.split('\n\n\t\t\t\t\t')
         # if(destinatario[0] === "Tutti") destinatario = ["ATA","Docenti","Studenti"]
       return item
    l = l.get()
    obj =
      protocollo: l[0],
      mittente: l[1],
      titolo: l[2],
      oggetto: l[3],
      data: l[4],
      destinatario: destinatario,
      link: link
    return obj
  tab = tab.get()
  tab.splice 0, 1
  done null, tab

downloadCircolari = (robot, callback) ->
  robot.http("http://galileicrema.it/Intraitis/comunicazioni/ComVis.asp?PerChi=Tutti")
    .get() (err, res, body) ->
      callback err, body

diffCircolari = (oldObj,newObj) ->
  diff = newObj.length - oldObj.length
  newObj.slice(0,diff)

parseCircolari = (err,data,callback) ->
  if err
    console.log(err)
  else
    parseHtml data, (err,res) -> callback res

module.exports = (robot) ->
  robot.respond /(?:mostrami|dimmi|fammi vedere) (?:le(?: ultime)? )?([0-9]+ )?circolari/i, (res) ->
    if res.match[1] is 0 then return
    res.send "sto controllando le circolari..."
    num = 10
    if not isNaN(res.match[1])
      num = parseInt res.match[1]
    downloadCircolari robot, (a,b) ->
      parseCircolari a, b, (x) ->
        list = x.slice 0, (num or 5)
        msg = list.map (c) ->
          ['('+c.protocollo.split('/')[0]+')','('+c.data+')',c.titolo].join(' ')
        res.send msg.join ' | '

  robot.respond /linkami (?:(?:la )?circolare )(?:(?:n(?:°)?(?: )?)|numero )?(\d+)/i, (res) ->
    base = "http://galileicrema.it/Intraitis/documenti/comunicazioni/2014/Circolare"
    res.send base+res.match[1]+'.pdf'

