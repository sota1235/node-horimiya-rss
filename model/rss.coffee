###

generate RSS2.0

###

{Buffer}  = require('buffer')
{Promise} = require('es6-promise')

request = require 'request'
path    = require 'path'
cheerio = require 'cheerio'
iconv   = require 'iconv'
async   = require 'async'
RSS     = require 'rss'

module.exports = class RSS_Maker

  constructor: ->
    @feedOptinos =
      'title'       : '読解アヘン - 堀さんと宮村くん'
      'description' : 'Web Comic by HERO'
      'feed_url'    : 'http://horimiya-rss.herokuapp.com'
      'site_url'    : 'http://dka-hero.com/'
      'image_url'   : 'http://dka-hero.com/banner.jpg'
      'author'      : 'sota1235'

  # URLからHTML全文を取得
  # 複数ページある場合はbody部を足し算してreturn
  # resolve itemOption
  _getOption: (uri, title) ->
    return new Promise (resolve, reject) ->
      param =
        url     : 'http://dka-hero.com/' + uri
        encoding: 'binary'
      dir = 'http://dka-hero.com/' + path.dirname uri
      request.get param, (err, res, html) ->
        if err
          reject err
        conv = new iconv.Iconv 'CP932', 'UTF-8//TRANSLIT//IGNORE'
        html = new Buffer html, 'binary'
        html = conv.convert(html).toString().replace /[\n\r]/g, ''
        body = html.match(/<body.*?>(.+?)<\/body>/)[1]
        body = body.replace /(src=")(.*?)(")/g, "$1" + dir + "/$2$3"
        itemOption =
          'title'      : title
          'url'        : 'http://dka-hero.com/' + uri
          'description': body
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
        console.log 'Make promises is completed'
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
