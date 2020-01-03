config = require "lapis.config"

config "production", ->
  session_name "realms2"
  secret os.getenv("SESSION_SECRET") or "secret"
  postgres ->
    host os.getenv("DB_HOST") or "postgres"
    user os.getenv("DB_USER") or "postgres"
    password os.getenv("DB_PASS") or "" -- I think this will work for nonexistant password but idgaf
    database os.getenv("DB_NAME") or "postgres"
  port 80
  num_workers 4
  digest_rounds 9
