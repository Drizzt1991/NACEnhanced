
###
    Module dependencies.
###

express = require('express')
routes = require('./routes')
user = require('./routes/test_socks')
http = require('http')
path = require('path')
sockjs = require('sockjs')
redis = require('redis')
connect_redis = require('connect-redis')
protocol = require('./protocol')

app = express();

redis_cli = redis.createClient();

RedisStore = connect_redis(express);

# all environments
app.set('port', process.env.PORT || 3000)
app.set('views', path.join(__dirname, './views'))
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.cookieParser('njkdasd1l;2k3joidua093j2kl1'))
app.use(express.session({
  secret: "ajkdljdopqclkxzmcklnmzxklc;kjasopdiq]powdkmakl;jxlka;sjd;lka",
  store: new RedisStore({ host: 'localhost', port: 6379, client: redis_cli })
}));
app.use(app.router)
app.use(express.static(path.join(__dirname, './public')))
app.use('/client', express.static(path.join(__dirname, '../client')))

# development only
if 'development' == app.get('env')
    app.use(express.errorHandler())

app.get('/', routes.index)
app.get('/test_socks.html', user.list)

# Define 'slots' for global state storage

# Connections, that await by the connect method.
app.pendingConnections = []; 
app.activeGames = [];

socks_server = sockjs.createServer()

socks_server.on('connection', (conn) -> 
    p = new protocol.Protocol(conn, app);
)

http_server = http.createServer(app)
socks_server.installHandlers(http_server, {prefix:'/socks_api'})

http_server.listen(
    app.get('port'), 
    () ->
        console.log('Express server listening on port ' + app.get('port')) 
)
