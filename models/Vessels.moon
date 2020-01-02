import Model from require "lapis.db.model"
import trim from require "lapis.util"

class Vessels extends Model
  @constraints: {
    name: (value) =>
      value = trim value

    attribute: (value) =>
      value = trim value
  }
