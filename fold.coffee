# **Fold.me** is a useful webapp to return urls of images
# of scottish fold cats for your delectation

#### Module dependencies.

coffee = require('coffee-script')
express = require('express')
redis = require('redis-url')
Set = require('Set')
everyauth = require('everyauth')

# redis connection uses provided URL (from Heroku) or connects localally
redis_connection = if process.env.REDISTOGO_URL then redis.connect(process.env.REDISTOGO_URL) else redis.connect()

everyauth['37signals']
  .appId(process.env.SIGNALS_APP_ID)
  .appSecret(process.env.SIGNALS_APP_SECRET)
  .redirectPath('/curate')
  .findOrCreateUser (sess, accessToken, accessSecret, _37signalsUser) ->
    _37signalsUser.identity

# Create the ExpressJS server object
app = express.createServer()

# Embelish the app with some view helpers for authentication
everyauth.helpExpress app

#### Configuration

scotch_key = 'scotch_folds'
organisation = process.env.ORGANISATION

app.configure () ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session({ secret: process.env.SESSION_SECRET })
  app.use app.router
  app.use express.static(__dirname + '/public')
  app.use everyauth.middleware()

app.configure 'development', () ->
  everyauth.debug = true
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

check_organisations = (accounts) ->
  org_url = "https://#{organisation}"
  console.log "org_url:", org_url
  console.log "accounts:", accounts
  console.log "hrefs:", (acc.href for acc in accounts)
  urls = (acc.href for acc in accounts when acc.href.lastIndexOf(org_url,0) == 0)
  console.log "urls:", urls
  urls.length > 0

authenticate = (req, res, next) ->
  if req.session.auth && check_organisations(req.session.auth['37signals'].user.accounts)
    next()
  else
    res.redirect('/auth/37signals')

loggedIn = (req) ->
  if req.session.auth
    req.session.auth.loggedIn

user_name = (req) ->
  if loggedIn(req)
    ident = req.session.auth['37signals'].user.identity
    "#{ident.first_name} #{ident.last_name}"
  else
    ""

#### Routes

app.get '/', (req, res) ->
  redis_connection.smembers "#{scotch_key}:curated", (err, reply) ->
    res.render 'folds_grid', {
      folds: reply,
      loggedIn: loggedIn(req),
      user_name: user_name(req)
    }

app.get '/count', (req, res) ->
  redis_connection.scard "#{scotch_key}:curated", (err, reply) ->
    res.json {fold_count: reply}

app.get '/random', (req, res) ->
  redis_connection.srandmember "#{scotch_key}:curated", (err, reply) ->
    res.json {scotch_fold: reply}

app.get '/bomb', (req, res) ->
  redis_connection.scard "#{scotch_key}:curated", (err, num_folds) ->
    bomb_count = parseInt req.query['count'] || 5
    if bomb_count > 20
      bomb_count = 20
    if bomb_count > num_folds
      redis_connection.smembers "#{scotch_key}:curated", (err, folds) ->
        res.json {scotch_folds: folds}
    else
      n_rand_items "#{scotch_key}:curated", bomb_count, (folds) ->
        res.json {scotch_folds: folds}

app.get '/curate', authenticate, (req, res) ->
  redis_connection.smembers "#{scotch_key}:uncurated", (err, reply) ->
    res.render 'curate', {
      uncurated_folds: reply,
      loggedIn: loggedIn(req),
      user_name: user_name(req)
    }

app.get '/ignored', authenticate, (req, res) ->
  redis_connection.smembers "#{scotch_key}:ignore", (err, reply) ->
    res.render 'folds_grid', {
      folds: reply,
      loggedIn: loggedIn(req),
      user_name: user_name(req)
    }

app.post '/fold.me', authenticate, (req, res) ->
  console.log "fold.me:", req.body
  fold = req.body.fold_url
  redis_connection.srem "#{scotch_key}:uncurated", fold
  redis_connection.sadd "#{scotch_key}:curated", fold
  res.json {fold: fold}

app.post '/not.fold', authenticate, (req, res) ->
  fold = req.body.fold_url
  redis_connection.srem "#{scotch_key}:uncurated", fold
  redis_connection.sadd "#{scotch_key}:ignore", fold
  res.json {fold: fold}

# Use Foreman's requested port if available
port = process.env.PORT ? 3300

# Start the app
app.listen(port)

# Be nice and say what port we started on
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env)

module.exports = app
