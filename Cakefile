coffee = require('coffee-script')
redis = require('redis-url')
google_images = require('./lib/google-images')
tumblr_images = require('./lib/tumblr-images')

redis_connection = if process.env.REDISTOGO_URL then redis.connect(process.env.REDISTOGO_URL) else redis.connect()

# Extra images to include
static_list = [
  'http://cuteoverload.files.wordpress.com/2011/06/tumblr_lkyec9ky311qjahcpo1_400.jpg?w=560',
  'http://static.gotpetsonline.com/pictures-gallery/cat-pictures-breeders-kittens-rescue/scottish-fold-pictures-breeders-kittens-rescue/pictures/scottish-fold-0017.jpg',
  'http://www.dogsww.com/Scottish%20fold%20cat%20seated.jpg',
  'http://kitten-kiev.com.ua/images/foto5.jpg',
  'http://www.catsofaustralia.com/images/Cailan.jpg',
  'http://upload.wikimedia.org/wikipedia/commons/7/7d/Scottish_Fold_P1050446e.jpg',
  'http://farm3.staticflickr.com/2688/4388087180_f93f374126.jpg',
  'http://www.kittenspictures.net/d/2939-2/Young+fury+Scottish+Fold+kitten+mixed.PNG',
  'http://2.bp.blogspot.com/-YI155s7afOA/TVRyGCrh8HI/AAAAAAAABVc/EfNG8t0BSms/s1600/scottish-fold-0008.jpg',
  'http://bestcatbreed.com/wp-content/uploads/2011/10/cute-scottish-fold-pictures.jpg'
]

saveStaticList = ->
  redis_connection.sadd 'scotch_folds:curated', static_list

uncurated = (urls, fun, vals) ->
  vals ||= []
  if urls.length == 0
    fun(vals)
  else
    next_url = urls.pop()
    redis_connection.sismember 'scotch_folds:curated', next_url, (err, reply) ->
      if reply == 0
        redis_connection.sismember 'scotch_folds:ignore', next_url, (err, reply) ->
          if reply == 0
            console.log("push", next_url)
            vals.push next_url
            uncurated(urls, fun, vals)
          else
            uncurated(urls, fun, vals)
      else
        uncurated(urls, fun, vals)

saveImages = (error, results) ->
  urls = (result.url for result in results)
  console.log(urls)
  uncurated urls, (uncurated_urls) ->
    console.log("uncurated_urls", uncurated_urls)
    if uncurated_urls.length > 0
      redis_connection.sadd 'scotch_folds:uncurated', uncurated_urls

updateImages = (query) ->
  console.log query
  (google_images.search query, {page: i*8, callback: saveImages} for i in [0..20])

tumblrImages = (number) ->
  tumblr_images "http://www.tumblr.com/tagged/scottish-fold", number, (images) ->
    uncurated images, (uncurated_images) ->
      if uncurated_images.length > 0
        console.log "Adding", uncurated_images.length, " images from tumblr"
        redis_connection.sadd 'scotch_folds:uncurated', uncurated_images

task 'images:update', 'fetch new images into the database', (options) ->
  tumblrImages(40)
  saveStaticList()
  #updateImages "scotch fold"
  #updateImages "scottish fold"
  console.log 'Done!!'
