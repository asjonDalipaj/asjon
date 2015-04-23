cheerio = require('cheerio')
fs = require('fs')

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
  # fs.writeFileSync('result.json',JSON.stringify(tab))  
  # console.log("saved file")
  done null, tab

downloadCircolari = (robot, callback) ->
  robot.http("http://galileicrema.it/Intraitis/comunicazioni/ComVis.asp?PerChi=Tutti")
    .get() (err, res, body) ->
      callback err, body

diffCircolari = (oldObj,newObj) ->
  diff = newObj.length - oldObj.length
  newObj.slice(0,diff)

circolari = []

parseCircolari = (err,data,callback) ->
  if err
    console.log(err)
  else
    parseHtml data, (err,res) ->
      #console.log("Done!")
      circolari = res
      fs.writeFile 'circolari/circolari.json', JSON.stringify circolari
      callback circolari

module.exports = (robot) ->
  robot.respond /circolari/i, (res) ->
    res.send 'controllo circolari...'
    fs.exists 'circolari/circolari.json', (jsonExists) ->
      if jsonExists
        circolari = JSON.parse fs.readFileSync('circolari/circolari.json').toString()
        res.send JSON.stringify circolari.slice 0,5
      else
        fs.exists 'circolari.html', (htmlExists) ->
          if htmlExists
            fs.readFile 'circolari/circolari.html', (a,b) -> parseCircolari a, b, (x) -> res.send JSON.stringify x.slice 0, 5
          else
            res.send "download circolari..."
            downloadCircolari robot, (a,b) ->
              res.send 'finito download...'
              parseCircolari a, b, (x) ->
                res.send 'invio...'
                res.send JSON.stringify x.slice 0, 5
