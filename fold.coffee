# Fold.me is a useful webapp to return urls of images
# of scottish fold cats for your delectation

#### Module dependencies.

coffee = require('coffee-script')
express = require('express')
redis = require('redis-url')
Set = require('Set')

# redis connection uses provided URL (from Heroku) or connects localally
redis_connection = if process.env.SOMEREDIS_URL then redis.connect(process.env.SOMEREDIS_URL) else redis.connect()

# Create the ExpressJS server object
app = module.exports = express.createServer()

#### Configuration

app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session({ secret: 'your secret goes here' })
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', () ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', () ->
  app.use express.errorHandler()

#### Helpers

# Returns a given number of random items from a redis key.
# Calls the provided callback function with the results
# E.g.
#
#     n_rand_items("woot", 5, (results) -> console.log(results))
n_rand_items = (key, n, callback, so_far = new Set([])) ->
  if so_far.size() < n
    redis_connection.srandmember key, (err, reply) ->
      so_far.add reply
      n_rand_items key, n, callback, so_far
  else
    callback so_far.toArray()

#### Routes

app.get '/', (req, res) ->
  res.render 'index', {
    title: 'Scottish Folds are awesome'
  }

app.get '/count', (req, res) ->
  redis_connection.scard 'scotch_folds', (err, reply) ->
    res.json {fold_count: reply}

app.get '/random', (req, res) ->
  redis_connection.srandmember 'scotch_folds', (err, reply) ->
    res.json {scotch_fold: reply}

app.get '/bomb', (req, res) ->
  redis_connection.scard 'scotch_folds', (err, num_folds) ->
    bomb_count = parseInt req.query['count']
    if bomb_count > num_folds
      redis_connection.smembers 'scotch_folds', (err, folds) ->
        res.json {scotch_folds: folds}
    else
      n_rand_items "scotch_folds", bomb_count, (folds) ->
        res.json {scotch_folds: folds}

port = process.env.PORT ? 3300
app.listen(port)
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)
