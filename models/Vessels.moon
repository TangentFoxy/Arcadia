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

  fullName: (indefinite_article) =>
    result = ""
    result = "#{@attribute} " if @attribute and @attribute\len! > 0
    result ..= @name
    if indefinite_article
      if result\sub(1, 1)\find "[AEIOUaeiou]"
        result = "an #{result}"
      else
        result = "a #{result}"
    return result
