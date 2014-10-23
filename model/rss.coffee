###

generate RSS2.0

###

Buffer  = require('buffer').Buffer
Promise = require('es6-promise').Promise

request = require 'request'
cheerio = require 'cheerio'
iconv   = require 'iconv'
async   = require 'async'
RSS     = require 'rss'

module.exports = class RSS_Maker

  # comiclist
  #   'title'      :
  #   'url'        :
  #   'description':
  constructor: ->
    @url      = 'http://dka-hero.com/'
    @feedOptinos =
      'title'       : '読解アヘン - 堀さんと宮村くん'
      'description' : 'Web Comic by HERO'
      'feed_url'    : 'http://horimiya-rss.herokuapp.com'
      'site_url'    : @url
      'image_url'   : 'http://dka-hero.com/banner.jpg'
      'author'      : 'sota1235'

  # URLからHTML全文を取得
  # 複数ページある場合はbody部を足し算してreturn
  # resolve itemOption
  _getOption: (url, title) ->
    host = 'http://dka-hero.com/'
    return new Promise (resolve, reject) ->
      request.get {url: host + url, encoding: 'binary'}, (err, res, html) ->
        if err
          reject 'hello' + err
        conv = new iconv.Iconv 'CP932', 'UTF-8//TRANSLIT//IGNORE'
        html = new Buffer html, 'binary'
        html = conv.convert(html).toString().replace /[\n\r]/g, ''
        body = html.match(/<body(.+)<\/body>/)
        itemOption =
          'title'      : title
          'url'        : url
          'description': body[1]
        resolve itemOption

  # 各話のurl, title取得
  # callback err, urlList
  _getComicList: () ->
    return new Promise (resolve, reject) ->
      param =
        url     : 'http://dka-hero.com/h_01.html'
        encoding: 'binary'
      urlList = {}
      request.get param, (err, res, body) ->
        if err
          reject err
        conv = new iconv.Iconv 'CP932', 'UTF-8//TRANSLIT//IGNORE'
        body = new Buffer body, 'binary'
        body = conv.convert body
        $ = cheerio.load body
        contents = cheerio.load $("a[target='contents']").each () ->
          href  = $(this).attr("href").toString()
          title = $(this).text().toString()
          if /^hm.+\/pict_com_\d+\.html$/.test href
            urlList[title] = href
          resolve urlList

  generateRSS: () ->
    feed = new RSS @feedOptinos
    _getComicList = @_getComicList
    _getOption    = @_getOption
    return new Promise (resolve, reject) ->
      _getComicList()
      .then (list) ->
        console.log 'getComicList() is completed'
        promises = []
        for title, url of list
          promises.push _getOption url, title
        return promises
      .then (promises) ->
        console.log 'make promises is completed'
        Promise.all promises
        .then (options) ->
          console.log 'Promise.all is completed'
          for option in options
            feed.item option
          resolve feed.xml ' '
        .catch (err) ->
          reject err
      .catch (err) ->
        reject err
