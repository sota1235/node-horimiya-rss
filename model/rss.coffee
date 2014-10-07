###

  generate RSS2.0

###

RSS = require 'rss'

module.exports = class RSS_Maker

  constructor: ->
    @db_url   = 'http://dka-hero.com'
    @list_url = '/h_01.html'
    @feedOptinos =
      'title'       : '読解アヘン - 堀さんと宮村くん'
      'description' : 'Web Comic by HERO'
      'feed_url'    : 'http://horimiya-rss.herokuapp.com'
      'site_url'    : @db_url
      'image_url'   : 'http://dka-hero.com/banner.jpg'
      'author'      : 'sota1235'

  getUrlList: (callback = ->) ->
    # TODO: それぞれのコミックページのURLリストをcallback
    callback url_list

  getItemOptions: (url, callbak = ->) ->
    # TODO: itemOptions用の配列を作成、callback
    callback itemOptions

  generateItems: (feed, callback = ->) ->
    item = []
    getUrlList (list) ->
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
      callback feed.toString
