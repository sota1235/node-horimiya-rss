path    = require 'path'
express = require 'express'

app = express()

app.set 'view engine', 'jade'
app.set 'view', path.resolve '/views'

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
, 1000 * 10

# Routing
app.get '/', (req, res) ->
  res.send 'Please reconnect to <a href="/feed">this page</a>.'

app.get '/feed', (req, res) ->
  res.render 'feed', {body: rss}

app.listen 3000
