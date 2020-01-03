import Model from require "lapis.db.model"

class Vessels extends Model
  @constraints: {
    name: (value) =>
      if value\find "%s"
        return "Vessel names cannot contain spaces."

    attribute: (value) =>
      if value\find "%s"
        return "Vessel attributes cannot contain spaces."
  }
