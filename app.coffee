path    = require 'path'
express = require 'express'

app = express()

app.set 'port', process.env.PORT || 3000
app.set 'view engine', 'jade'
app.set 'views', path.resolve 'views/'

# 10分毎にRSSを生成
RssMaker = require path.resolve 'model/rss.coffee'
RSS = new RssMaker
rss = null
RSS.generateRSS()
.then (result) ->
  rss = result
.catch (err) ->
  console.error err

setInterval () ->
  RSS.generateRSS()
  .then (result) ->
    rss = result
  .catch (err) ->
    console.error err
, 1000 * 60 * 10

# Routing
app.get '/', (req, res) ->
  res.send 'Please reconnect to <a href="/feed">this page</a>.'

app.get '/feed', (req, res) ->
  res.set
    "Content-Type": "text/xml"
  res.send rss

app.listen app.get 'port'

# Herokuが寝ないようにする
# http://gyazz.masuilab.org/Herokuが寝ないようにする
return unless /^https?:\/\/.+/.test process.env.HEROKU_URL

setInterval ->
  debug 'ping'
  url = "#{process.env.HEROKU_URL}?keepalive=#{Date.now()}"
  request.head url, (err, res) ->
    if res.statusCode is 200
      debug 'pong'
, 60 * 1000 * 20 # 20 min
