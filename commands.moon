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

local parse
parse = {
  articles: { "a", "an", "the" }
  prepositions: { "in", "into", "to" }
  vessel: (args) ->
    local attribute, name, id
    return {} if #args < 1
    for article in *parse.articles
      if args[1]\lower! == article
        table.remove args, 1
        break
    return {} if #args < 1
    return {} if parse.preposition args
    unknown = table.remove(args, 1)\lower!
    if preposition = parse.preposition args
      return { name: unknown }
    return { name: unknown } if #args < 1
    name = table.remove(args, 1)\lower!
    id = tonumber name
    if id and id == math.floor id
      return { :id }
    else
      return { attribute: unknown, name: name }
  preposition: (args) ->
    return nil if #args < 1
    for preposition in *parse.prepositions
      if args[1]\lower! == preposition
        return preposition
  complex_command: (args) ->
    local a, b, preposition
    a = parse.vessel(args)
    if preposition = parse.preposition(args)
      table.remove(args, 1)
    b = parse.vessel(args)
    return a, b, preposition
}

local match
match = {
  vessel: (data, vessels) ->
    if data.name
      for vessel in *vessels
        if data.name == vessel.name
          if not data.attribute or data.attribute == vessel.attribute
            return vessel
    elseif data.id
      for vessel in *vessels
        if data.id == vessel.id
          return vessel
    return nil, "No such vessel."
  action: (args, vessels, fn) ->
    data = parse.vessel(args)
    if vessel = match.vessel(data, vessels)
      return fn(vessel)
    return nil, "No such vessel."
  multiple: (data, vessels) ->
    matches = {}
    if data.id
      for vessel in *vessels
        if data.id == vessel.id
          return { vessel }
    elseif data.name
      for vessel in *vessels
        if data.name == vessel.name
          if not data.attribute or data.attribute == vessel.attribute
            table.insert matches, vessel
      return matches
    return {}
}

make = {}
make.list = (vessels) ->
  result = ""
  for vessel in *vessels
    result ..= ", #{vessel\fullName true}"
  result = result\sub 3
  switch #vessels
    when 0
      return nil
    when 1
      return result
    when 2
      return result\gsub(", ", " and ")
    else
      local x, y
      i, j = result\find ", "
      while i
        x, y = i, j
        i, j = result\find ", ", j + 1
      return "#{result\sub 1, x} and#{result\sub y}"

local commands
commands = {
  account: (args) =>
    switch table.remove(args, 1)\lower!
      when "create"
        @action = "Welcome #{args[1]}!"
        response, err = Users\create {
          name: args[1]
          digest: args[2] and bcrypt.digest(args[2], config.digest_rounds)
          email: args[3]
          vessel_id: 2 -- everyone starts possessing the ghost
        }
        @session.id = response.id if response
        return response, err
      when "login"
        if @user = Users\find name: args[1]
          verified = not @user.digest
          if @user.digest
            if bcrypt.verify args[2], @user.digest
              verified = true
          if verified
            @session.id = @user.id
            return "Welcome #{@user.name}!"
        return nil, "Invalid username or password."
      when "logout"
        @action = "You are logged out."
        @session.id = nil
      when "delete"
        if @user
          @action = "Your account has been deleted."
          return @user\delete!
        else
          return nil, "You are not logged into an account."
      when "rename"
        nil, "To be implemented."
      when "password"
        nil, "To be implemented."
      when "email"
        nil, "To be implemented."
      when "show"
        local result
        if @user
          result = "Logged in as #{@user.name}"
          if @user.email and @user.email\len! > 0
            result ..= " (#{@user.email})"
          if @user.digest
            result ..= ", password-protected"
        else
          result = "Not logged in"
        return result .. ".\nYou are possessing #{@current\fullName true}."
      else
        nil, "Invalid command."
  -- message: (args) => -- (article) (username|"admin") string

  create: (args) =>
    data = parse.vessel args
    unless data.name and data.name\len! > 0
      return nil, "Vessels must be named!"
    @action = "You created #{@current.fullName(data, true)}."
    return Vessels\create {
      name: data.name
      attribute: data.attribute or ""
      note: ""
      parent: @current.parent
    }
  become: (args) =>
    unless @user
      return "You must be logged into an account to become another vessel (run 'learn to account' to learn how to create or login to an account)."
    match.action args, @here, (v) ->
      @action = "You became #{v\fullName true}."
      return @user\update vessel_id: v.id

  transform: (args) =>
    a, b, preposition = parse.complex_command(args)
    return nil, "Invalid transform command." if not preposition or preposition == "in"
    if v = match.vessel a, @here -- non-attribute transformations
      @action = "You transformed #{v\fullName(true)} into #{v.fullName(b, true)}."
      return v\update {
        attribute: b.attribute or ""
        name: b.name
      }
    return nil, "Invalid transform command." if b.attribute -- only b.name should exist (and is actually an attribute)
    matches = {}
    for vessel in *@here
      if vessel.attribute == a.name -- this is actually an attribute to search for!
        table.insert matches, vessel
    errors = {}
    if #matches > 0
      for vessel in *matches
        response, err = vessel\update attribute: b.name -- again, actually an attribute
        table.insert(errors, err) unless response
    else
      return nil, "No such vessel(s)."
    if #errors > 0
      return nil, table.concat errors, "\n"
    else
      return "You transformed all #{a.name} into #{b.name}."
  note: (args) =>
    note = table.concat args, " "
    @action = "You changed the note on #{@parent\fullName true}."
    return @parent\update { note: note or "" }

  warp: (args) =>
    a, b, preposition = parse.complex_command(args)
    return nil, "Invalid warp command." if not preposition
    if a and (a.name or a.id)
      a = match.vessel a, @here
    else
      a = @current
    unless a
      return nil, "No such target vessel."
    b = Vessels\find attribute: b.attribute, name: b.name, id: b.id
    if b
      if a == @current
        @action = "You warped"
      else
        @action = "You warped #{a\fullName(true)}"
      @action ..= " #{preposition} #{b\fullName(true)}."
      if preposition == "to"
        return a\update parent: b.parent
      else -- in, into
        return a\update parent: b.id
    else
      return nil, "No such destination vessel."
  move: (args) =>
    a, b, preposition = parse.complex_command(args)
    return nil, "Invalid move command." if not preposition or preposition == "to" or not (a and b)
    a = match.vessel a, @here
    b = match.vessel b, @here
    return nil, "No such vessel." if not (a and b)
    @action = "You moved #{a\fullName true} into #{b\fullName true}."
    return a\update parent: b.id
  enter: (args) =>
    match.action args, @here, (v) ->
      @action = "You entered #{v\fullName true}."
      return @current\update parent: v.id
  leave: (args) =>
    if @parent.id == @parent.parent
      return "You cannot leave #{@parent\fullName true}."
    @action = "You left #{@parent\fullName true}."
    return @current\update parent: @parent.parent

  take: (args) =>
    match.action args, @here, (v) ->
      @action = "You took #{v\fullName true}."
      return v\update parent: @current.id
  drop: (args) =>
    match.action args, @inventory, (v) ->
      @action = "You dropped #{v\fullName true}."
      return v\update parent: @current.parent

  look: (args) =>
    vessels = {}
    for vessel in *@here
      unless vessel.id == @current.id or vessel.id == vessel.parent -- don't see yourself or a paradox
        table.insert vessels, vessel
    output = {}
    if @parent.note and @parent.note\len! > 0
      table.insert output, @parent.note
    if result = make.list vessels
      table.insert output, "You see #{result} here."
    else
      table.insert output, "There are no other vessels here."
    return table.concat output, "\n"
  inventory: (args) =>
    vessels = {}
    for vessel in *@inventory
      unless vessel.id == @current.id -- don't see yourself (a paradox)
        table.insert vessels, vessel
    if result = make.list vessels
      return "You are carrying #{result}."
    else
      return "You are not carrying anything."
  inspect: (args) =>
    if data = parse.vessel args
      result = ""
      for vessel in *(match.multiple data, @here)
        name = vessel\fullName true
        result ..= "#{name\sub(1, 1)\upper!}#{name\sub 2}, ID: #{vessel.id}\n"
        if vessel.note and #vessel.note > 0
          result ..= "#{vessel.note}\n"
      if result\len! > 0
        return result\sub 1, -2 -- remove last newline
      return nil, "No such vessel."
    return nil, "Invalid inspect command."

  learn: (args) =>
    if #args > 0
      for ignorable in *{ "about", "to" }
        if args[1]\lower! == ignorable
          table.remove args, 1
          break
    topic = table.concat args, " "
    if topic\len! < 1
      return helptext.learn
    elseif helptext[topic]
      return helptext[topic]
    else
      return nil, "No such information."
}

class extends lapis.Application
  @path: "/command"

  [command: ""]: respond_to {
    GET: =>
      return layout: false, status: 405, "Method not allowed."

    POST: json_params =>
      args = split(@params.command)
      command = string.lower table.remove args, 1

      if @session.id
        @user = Users\find id: @session.id
      @current = Vessels\find id: @user and @user.vessel_id or 2
      @parent = Vessels\find id: @current.parent
      @here = Vessels\select "WHERE parent = ?", @current.parent
      @inventory = Vessels\select "WHERE parent = ?", @current.id

      output = {}

      if commands[command]
        response, err = commands[command](@, args)
        if err
          table.insert(output, "[[;red;]#{err}]") -- TODO escape brackets
        elseif @action
          table.insert(output, @action) -- TODO escape brackets
        elseif response
          table.insert(output, response) -- TODO escape brackets
      else
        table.insert output, "[[;red;]Unknown command.]"

      -- TODO local area text to output with the rest!

      return layout: false, table.concat output, "\n"
  }
