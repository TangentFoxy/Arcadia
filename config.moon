config = require "lapis.config"

config "production", ->
  session_name "realms2"
  secret os.getenv "SESSION_SECRET"
  postgres ->
    host os.getenv "DB_HOST"
    user os.getenv "DB_USER"
    password os.getenv "DB_PASS"
    database os.getenv "DB_NAME"
  port 80
  num_workers 4
  digest_rounds 9
