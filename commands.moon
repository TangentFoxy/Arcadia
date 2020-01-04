lapis = require "lapis"
config = require("lapis.config").get!
bcrypt = require "bcrypt"

import Vessels, Users from require "models"
import respond_to, json_params from require "lapis.application"

split = (str) ->
  tab = {}
  for word in str\gmatch "%S+"
      table.insert tab, word
  return tab
copy = (tab) ->
  new = {}
  for k,v in pairs tab
    new[k] = v
  return new

articles = { "a", "an", "the" }
parseVessel = (args) ->
  local attribute, name, id, article
  words = copy(args)
  return nil if #words < 1
  for article in *articles
    if words[1]\lower! == article
      article = table.remove(words, 1)\lower!
      break
  return nil if #words < 1
  -- TODO support any ??? (just tell caller that 'any' article was removed)
  attribute = table.remove(words, 1)\lower! if #words > 1
  name = table.remove(words, 1)\lower! if #words > 0
  if name
    if index = name\find "#"
      id = tonumber name\sub index + 1
      name = name\sub 1, index - 1
  return { :attribute, :name, :id, :article }
fullName = (vessel, indefinite_article) ->
  result = ""
  result = "#{vessel.attribute} " if vessel.attribute and vessel.attribute\len! > 0
  result ..= vessel.name
  if indefinite_article
    if result\sub(1, 1)\find "[AEIOUaeiou]"
      result = "an #{result}"
    else
      result = "a #{result}"
  return result
listVessels = (vessels, errMsg) ->
  result = ""
  for vessel in *vessels
    result ..= ", #{fullName vessel, true}"
  switch #vessels
    when 0
      return errMsg
    when 1
      return "You see #{result\sub 3} here."
    when 2
      return "You see #{result\sub(3)\gsub(", ", " and ")} here."
    else
      local x, y
      i, j = result\find ", "
      while i
        x, y = i, j
        i, j = result\find ", ", j + 1
      result = "#{result\sub(1, x)} and#{result\sub(y)}"
      return "You see #{result\sub(3)} here."

commands = {
  -- IDEA replace login / logout commands with 'account' command for creation, modification, deletion
  --       minimum top-level commands is what I want, prevents introducing even more account commands later
  -- () required, [] optional, | inclusive or, <> no arguments, "" literal value
  login: (args) =>  -- (username) [password] [email]
    if user = Users\find name: args[1]
      verified = not user.digest -- automatically verified if they don't have a password :3 yes this is maybe evil
      if user.digest
        if bcrypt.verify args[2], user.digest
          verified = true
      if verified
        @session.id = user.id
      else
        return nil, "Invalid username or password."
      if args[3]
        success, err = user\update email: args[3]
        if success
          return "Welcome back, #{user.name}. Your email address has been updated."
        else
          return "You are logged in.\n[[;red;]There was an error updating your email address: #{err}]"
    else
      user, err = Users\create {
        name: args[1]
        digest: args[2] and bcrypt.digest(args[2], config.digest_rounds)
        email: args[3]
        vessel_id: 2 -- everyone starts as the ghost :3
      }
      if user
        @session.id = user.id
        return "Welcome #{user.name}! Type 'learn' to learn how to interact with the Realms."
      else
        return nil, "There was an error while attempting to create a new account: #{err}"
  logout: (args) => -- ["--delete"]
    -- TODO implement account deletion
    was_logged_in = @session.id
    @session.id = nil
    if was_logged_in
      return "You have been logged out."
    else
      return nil, "You are not logged in."
  -- message: (args) => -- [article] [username|"admin"] (string)

  create: (args) => -- [article] [attribute] (name)
    data = parseVessel args
    unless data.name and data.name\len! > 0
      return nil, "Vessels must be named!"
    vessel, err = Vessels\create {
      name: data.name
      attribute: data.attribute or ""
      note: ""
      parent: @current.parent
    }
    if vessel
      return "You created #{fullName vessel, true}."
    else
      return nil, "Error: #{err}"
  become: (args) => -- [article] [attribute] (name|id)
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.parent
      success, err = @user\update vessel_id: vessel.id
      if success
        return "You became #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "There is no such vessel here."

  -- transform: (args) => -- [article] [attribute]|[(name|id)] [(into) [article] [attribute]|[(name|id)]]
  note: (args) =>      -- (string)
    note = table.concat args, " "
    if vessel = Vessels\find id: @current.parent
      success, err = vessel\update { note: note or "" }
      if success
        return "You changed the note on #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      -- NOTE should compose a message to admin
      return nil, "Error: A possessed vessel exists with an invalid parent ID."

  -- warp: (args) =>  -- [article] [attribute] (name|id) (to) [article] [attribute] (name|id)
  -- move: (args) =>  -- [article] [attribute] (name|id) (to) [article] [attribute] (name|id)
  enter: (args) => -- [article] [attribute] (name|id)
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.parent
      success, err = @current\update parent: vessel.id
      if success
        return "You entered #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "There is no such vessel here."
  leave: (args) => -- <no arguments>
    if vessel = Vessels\find id: @current.parent
      success, err = @current\update parent: vessel.parent
      if success
        return "You left #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      -- NOTE should compose a message to admin
      return nil, "Error: A possessed vessel exists with an invalid parent ID."

  take: (args) => -- [article] [attribute] (name|id)
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.parent
      success, err = vessel\update parent: @current.id
      if success
        return "You took #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "There is no such vessel here."
  drop: (args) => -- [article] [attribute] (name|id)
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.id
      success, err = vessel\update parent: @current.parent
      if success
        return "You dropped #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "You do not have any such vessel."

  look: (args) =>      -- [[to] [article] [attribute] (name|id)]
    -- TODO future feature: looking in places besides current location
    if vessels = Vessels\select "WHERE parent = ?", @current.parent
      list = {}
      for vessel in *vessels
        unless vessel.id == @current.id
          table.insert list, vessels
      return listVessels list, "There are no other vessels here."
    else
      -- NOTE should message an admin
      return nil, "Error: A selection query didn't return an empty list."
  inventory: (args) => -- <no arguments>
    if vessels = Vessels\select "WHERE parent = ?", @current.id
      return listVessels vessels, "You are not carrying anything."
    else
      -- NOTE should message admin
      return nil, "Error: A selection query didn't return an empty list."
  inspect: (args) =>   -- [article] [attribute] (name|id)
    local vessel
    data = parseVessel args
    if data.id
      vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id
    else
      vessel = Vessels\find name: data.name, attribute: data.attribute, parent: @current.parent
    if vessel
      -- TODO will display more info in the future
      name = fullName vessel, true
      return "#{name\sub(1, 1)\upper!}#{name\sub(2)}, ID: #{vessel.id}"
    else
      return nil, "There is no such vessel."

  -- learn: (args) => -- [[about] (string)]
}
-- NOTE the following may be introduced as subcommands of 'account'
-- whoami or 'who am i' (inspect self basically.. except on user, not vessel!)
-- list (admin: list users) (alt: count: users can see how many accounts exist)
-- online (list online users)
-- rename (change your username)
-- chmail (change your email address)
-- chpass (change your password)

class extends lapis.Application
  @path: "/command"

  [command: ""]: respond_to {
    GET: =>
      return layout: false, status: 405, "Method not allowed."

    POST: json_params =>
      args = split(@params.command)
      command = table.remove args, 1

      if @session.id
        @user = Users\find id: @session.id
        if @user
          @current = Vessels\find id: @user.vessel_id
          -- NOTE should message admin
          return "[[;red;]Error: A user account exists without a valid possessed vessel.]" unless @current
        else
          @session.id = nil

      if not @user and command != "login" and command != "learn"
        return layout: false, status: 401, "[[;red;]Please log in first.]"

      if commands[command]
        res, err = commands[command](@, args)
        return layout: false, res or "[[;red;]#{err}]"
      else
        return layout: false, status: 400, "[[;red;]Unknown command.]"
  }
