jsdom = require('jsdom')

biggerImage = (image) ->
  image.replace(/_[\d]{3}\.([\w]{3,4})$/, '_500.$1')

getTaggedImages = (url, callback) ->
  jsdom.env url, ["http://code.jquery.com/jquery-1.7.2.min.js"], (errors, window) ->
    images = (biggerImage(img.src) for img in window.$('.post_content img'))
    next_page = window.$('#next_page_link').attr('href').replace(' ', '-')
    next_link = "http://www.tumblr.com#{next_page}"
    callback(images, next_link)

iterateSearch = (url, i, callback, values) ->
  values ||= []
  if i == 0
    callback(values)
  else
    console.log "getTaggedImages..."
    getTaggedImages url, (images, next_link) ->
      all_images = values.concat images
      console.log "next_link:", next_link, "i:", i-1
      iterateSearch next_link, i-1, callback, all_images

module.exports = iterateSearch
