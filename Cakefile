coffee = require('coffee-script')
redis = require('redis-url')
google_images = require('google-images')

redis_connection = if process.env.REDISTOGO_URL then redis.connect(process.env.REDISTOGO_URL) else redis.connect()

# Extra images to include
static_list = [
  'http://cuteoverload.files.wordpress.com/2011/06/tumblr_lkyec9ky311qjahcpo1_400.jpg?w=560'
]

uncurated = (urls, fun, vals) ->
  vals ||= []
  if urls.length == 0
    fun(vals)
  else
    next_url = urls.pop()
    redis_connection.sismember 'scotch_folds:curated', next_url, (err, reply) ->
      if reply == 0
        console.log("push", next_url)
        vals.push next_url
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
  (google_images.search query, {page: i, callback: saveImages} for i in [0..100])

task 'images:update', 'fetch new images into the database', (options) ->
  updateImages "scotch fold"
  updateImages "scottish fold"
  console.log 'Done!!'
