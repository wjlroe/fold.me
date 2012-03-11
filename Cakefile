coffee = require('coffee-script')
redis = require('redis-url')
google_images = require('./lib/node-google-images')

updateImages = (query) ->
  redis_connection = if process.env.SOMEREDIS_URL then redis.connect(process.env.SOMEREDIS_URL) else redis.connect()
  google_images.searchPages query, 5, (results) ->
    urls = (result.url for result in results)
    console.log(urls)
    redis_connection.sadd 'scotch_folds', urls

task 'images:update', 'fetch new images into the database', (options) ->
  updateImages "scotch fold"
  updateImages "scottish fold"
