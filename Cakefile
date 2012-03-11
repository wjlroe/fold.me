coffee = require('coffee-script')
redis = require('redis-url')
google_images = require('google-images')

updateImages = (query) ->
  redis_connection = if process.env.REDISTOGO_URL then redis.connect(process.env.REDISTOGO_URL) else redis.connect()
  google_images.searchPages query, 5, (results) ->
    urls = (result.url for result in results)
    console.log(urls)
    redis_connection.sadd 'scotch_folds', urls

task 'images:update', 'fetch new images into the database', (options) ->
  updateImages "scotch fold"
  updateImages "scottish fold"
