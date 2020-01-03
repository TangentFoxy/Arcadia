import Model from require "lapis.db.model"

class Users extends Model
  @constraints: {
    name: (value) =>
      if not value or value\len! < 1
        return "You must enter a username."

      if value\find "%s"
        return "Usernames cannot contain spaces."

      if value\lower! == "admin"
        return "That username is unavailable."

      if Users\find name: value
        return "That username is unavailable."

    email: (value) =>
      if value
        if value\find "%s"
          return "Email addresses cannot contain spaces."

        if value\len! > 0 and Users\find email: value
          return "That email address is already tied to an account."
  }

  @relations: {
    { "vessel", has_one: "Vessels" }
  }
