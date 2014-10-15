###

  generate RSS2.0

###

Buffer  = require('buffer').Buffer

request = require 'request'
cheerio = require 'cheerio'
iconv   = require 'iconv'
RSS = require 'rss'

module.exports = class RSS_Maker

  constructor: ->
    @db_url   = 'http://dka-hero.com/'
    @feedOptinos =
      'title'       : '読解アヘン - 堀さんと宮村くん'
      'description' : 'Web Comic by HERO'
      'feed_url'    : 'http://horimiya-rss.herokuapp.com'
      'site_url'    : @db_url
      'image_url'   : 'http://dka-hero.com/banner.jpg'
      'author'      : 'sota1235'

  # 引数のページコンテンツを取得
  # callback err, contents
  getPageContents: (url, callback = ->) ->
    request.get {url: @db_url + url, encoding: 'binary'}, (err, res, body) ->
      if err
        callback err, null
        return
      re   = /<body>(.+)<\/body>/
      conv = new iconv.Iconv 'CP932', 'UTF-8//TRANSLIT//IGNORE'
      body = new Buffer body, 'binary'
      body = conv.convert body
      body = body.toString().replace(/[\n\r]/g, '')
      callback null, body.match(re)[1]

  # 各話のurl取得
  # callback err, list
  getUrlList: (callback = ->) ->
    url_list = []
    request.get {url: @db_url + 'h_01.html', encoding: 'binary'}, (err, res, body) ->
      if err
        callback err, null
        return
      conv = new iconv.Iconv 'CP932', 'UTF-8//TRANSLIT//IGNORE'
      body = new Buffer body, 'binary'
      body = conv.convert body
      $ = cheerio.load body
      contents = cheerio.load $("a[target='contents']").each () ->
        href = $(this).attr "href"
        if /^hm.+\/pict_com_\d+\.html$/.test href
          url_list.push href
      callback null, url_list

  getItemOptions: (url, callbak = ->) ->
    # TODO: itemOptions用の配列を作成、callback
    callback itemOptions

  generateItems: (feed, callback = ->) ->
    item = []
    getUrlList (err, list) ->
      for url in list
        itemOptions = null
        # TODO: itemOptions内をスクレイピング
        getPageContents url, (options) ->
          itemOptions = options
          item.push itemOptions
    callback feed.item item

  generateRSS: (callback = ->) ->
    feed = new RSS @feedOptions
    generateItems feed, (feed) ->
      callback feed.xml 4
