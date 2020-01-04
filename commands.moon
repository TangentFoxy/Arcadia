lapis = require "lapis"
config = require("lapis.config").get!
bcrypt = require "bcrypt"
helptext = require "helptext"

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
prepositions = { "in", "into", "to" }
parseVessel = (args) ->
  local attribute, name, id, article
  words = copy(args)
  return nil if #words < 1
  for article in *articles
    if words[1]\lower! == article
      article = table.remove(words, 1)\lower!
      break
  return nil if #words < 1
  attribute = table.remove(words, 1)\lower! if #words > 1
  name = table.remove(words, 1)\lower! if #words > 0
  if name
    if index = name\find "#"
      id = tonumber name\sub index + 1
      if id
        name = name\sub 1, index - 1
        if name\len! < 1
          name = nil
  return { :attribute, :name, :id, :article }
getPreposition = (args) ->
  for i, preposition in ipairs prepositions
    if args[1]\lower! == preposition
      return args[1]\lower!, i
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
  -- name by itself is required, () optional, | inclusive or, <> no arguments, "" literal value
  login: (args) =>  -- username (password) (email)
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
        -- TODO message admin
        return nil, "There was an error while attempting to create a new account: #{err}"
  logout: (args) => -- ("--delete")
    was_logged_in = @session.id
    @session.id = nil
    if was_logged_in
      if args[1] == "--delete"
        success, err = @user\delete!
        if success
          return "You have been logged out. Your account has been deleted."
        else
          -- TODO send admin message
          return "You have been logged out. [[;red;]There was an error deleting your account: #{err}]"
      return "You have been logged out."
    else
      return nil, "You are not logged in."
  -- message: (args) => -- (article) (username|"admin") string

  create: (args) => -- (article) (attribute) name
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
  become: (args) => -- (article) (attribute) name#id
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.parent
      success, err = @user\update vessel_id: vessel.id
      if success
        return "You became #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "There is no such vessel here."

  transform: (args) => -- (article) (attribute|name#id) into (article) (attribute|name)
    local vessels, i
    for j, word in ipairs args
      if word\lower! == "into"
        i = j
    unless i
      return nil, "Invalid transform command."
    a = {}
    while i > 1
      table.insert a, table.remove args, 1
      i -= 1
    table.remove args, 1
    a = parseVessel a
    data = parseVessel args
    if a.id
      vessel = Vessels\find name: a.name, attribute: a.attribute, id: a.id
      vessels = { vessel }
    else
      vessels = Vessels\select "WHERE name = ? AND attribute = ? AND parent = ?", a.name, a.attribute, @current.parent
    if not vessels or #vessels < 1
      if a.name and not a.attribute
        vessels = Vessels\select "WHERE attribute = ? AND parent = ?", a.attribute, @current.parent
    if not vessels or #vessels < 1
      return nil, "There are no such vessels to transform."
    errs = ""
    unless data.name or data.attribute
      data.attribute = "" -- must be removing an attribute
    for vessel in *vessels
      success, err = vessel\update {
        attribute: data.attribute
        name: data.name
      }
      unless success
        errs ..= err .. "\n"
    local result
    if data.name
      if data.attribute and data.attribute\len! > 0
        result = "You transformed #{a.attribute or a.name} into #{data.attribute} #{data.name}."
      else
        result = "You transformed #{a.attribute or a.name} into #{data.name}."
    else
      if data.attribute and data.attribute\len! > 0
        result = "You transformed #{a.attribute} into #{data.attribute}."
      else
        result = "You transformed #{a.attribute} into #{data.name}."
    if #errs > 0
      return "#{result}[[;red;]However, there were errors: #{errs}]"
    else
      return result
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

  warp: (args) =>  -- ((article) (attribute) name#id) preposition (article) (attribute) name#id
    preposition, i = getPreposition args
    unless preposition
      return nil, "Invalid warp command."
    a = {}
    while i > 1
      table.insert a, table.remove args, 1
      i -= 1
    table.remove args, 1
    a = parseVessel a
    data = parseVessel args
    vessel = Vessels\find name: a.name, attribute: a.attribute, id: a.id, parent: @current.parent
    unless vessel
      if not a.name or a.attribute or a.id
        vessel = @current
      else
        return nil, "There is no such target vessel."
    if destination = Vessels\find name: data.name, attribute: data.attribute, id: data.id
      if preposition == "to"
        vessel.parent = destination.parent
        return "You warped #{vessel.id != @current.id and "#{fullName vessel, true} "}to #{fullName destination, true}."
      else
        vessel.parent = destination.id
        return "You warped #{vessel.id != @current.id and "#{fullName vessel, true} "}into #{fullName destination, true}."
    else
      return nil, "There is no such destination vessel."
  move: (args) =>  -- (article) (attribute) name#id preposition (article) (attribute) name#id
    preposition, i = getPreposition args
    unless preposition
      return nil, "Invalid move command."
    a = {}
    while i > 1
      table.insert a, table.remove args, 1
      i -= 1
    table.remove args, 1
    a = parseVessel a
    data = parseVessel args
    vessel = Vessels\find name: a.name, attribute: a.attribute, id: a.id, parent: @current.parent
    unless vessel
      return nil, "There is no such target vessel."
    if destination = Vessels\find name: data.name, attribute: data.attribute, id: data.id
      vessel.parent = destination.id
      return "You moved #{fullName vessel, true} into #{fullName destination, true}."
    else
      return nil, "There is no such destination vessel."
  enter: (args) => -- (article) (attribute) name#id
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

  take: (args) => -- (article) (attribute) name#id
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.parent
      success, err = vessel\update parent: @current.id
      if success
        return "You took #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "There is no such vessel here."
  drop: (args) => -- (article) (attribute) name#id
    data = parseVessel args
    if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.id
      success, err = vessel\update parent: @current.parent
      if success
        return "You dropped #{fullName vessel, true}."
      else
        return nil, "Error: #{err}"
    else
      return nil, "You do not have any such vessel."

  look: (args) =>      -- ((preposition) (article) (attribute) name#id)
    local vessels
    if getPreposition args -- result ignored, but needs to not be present for parseVessel
      table.remove args, 1
    if #args > 0
      data = parseVessel args
      if vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id, parent: @current.id
        vessels = Vessels\select "WHERE parent = ?", vessel.id
    else
      vessels = Vessels\select "WHERE parent = ?", @current.parent
      if vessels
        for i, vessel in ipairs vessels
          if vessel.id == @current.id
            table.remove vessels, i
            break
    if vessels
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
  inspect: (args) =>   -- (article) (attribute) name#id
    local vessels
    data = parseVessel args
    if data.id
      vessel = Vessels\find name: data.name, attribute: data.attribute, id: data.id
      vessels = { vessel }
    else
      vessels = Vessels\select "WHERE name = ? AND attribute = ? AND parent = ?", data.name, data.attribute, @current.parent
    result = ""
    for vessel in *vessels
      -- NOTE in future, should display more info
      name = fullName vessel, true
      result ..= "#{name\sub(1, 1)\upper!}#{name\sub(2)}, ID: #{vessel.id}\n"
    if result\len! > 0
      return result\sub 1, -2 -- remove last newline
    else
      return nil, "There is no such vessel."

  learn: (args) => -- ("about"|"to") string
    for about in *{ "about", "to" }
      if args[1]\lower! == about
        table.remove args, 1
        break
    topic = table.concat args, " "
    if topic\len! < 1
      return helptext.learn
    elseif helptext[topic]
      return helptext[topic]
    else
      return nil, "There is no help for '#{topic}' available."
}

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
