coffee = require('coffee-script')
redis = require('redis-url')

redis_connection = if process.env.SOMEREDIS_URL then redis.connect(process.env.SOMEREDIS_URL) else redis.connect()

seed_data = ["http://funniespet.com/cute-scottish-fold-kittens.html/cute-scottish-fold-kitten-4",
             "http://bestcatbreed.com/wp-content/uploads/2011/10/scottish-fold-kitten.jpg",
             "http://3.bp.blogspot.com/-psSGspIVuz0/TeZFfIbHv2I/AAAAAAAABGM/HLvHfkQn8oY/s1600/ScottishFold.jpg",
             "http://www.dogsww.com/Scottish%20fold%20cat%20seated.jpg",
             "http://s2.hubimg.com/u/2990197_f260.jpg",
             "http://www.ellemaddox.com/wp-content/uploads/2011/11/scottish-fold-kittens-for-re-homing-100bhd_2.jpg",
             "http://4.bp.blogspot.com/_uH6j5NEBh5Q/TTFar4d5vaI/AAAAAAAAAEY/tSGl6DHrGhg/s400/Scottish-fold-cat-standards_222222222222.jpg",
             "http://www.montessoricats.com/buddha-scottish-fold-its-magic.jpg"
]

redis_connection.sadd("scotch_folds", seed_data)
