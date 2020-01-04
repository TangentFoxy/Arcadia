topics = {}

topics.login = [[
[[;white;]login username (password) (email)]
 Creates or logs into an existing account.
 Passwords are optional but recommended.
 Email address is optional and not currently used for anything in the game itself. It may be used to inform the user of updates at a future date.

New accounts will possess the vessel with id 2. It is recommended you [[;white;]create] a vessel and [[;white;]become] it, or else you may end up sharing the same vessel with others!
]]

topics.logout = [[
[[;white;]logout ("--delete")]
 Logs out of an account.
 If "--delete" is specified, deletes the account.
]]

topics.create = [[
[[;white;]create (article) (attribute) name]
 Creates a vessel.
 Articles (a, an, the) are ignored.
 Attributes are usually displayed with a vessel's name.
 Vessels must be named, names cannot have spaces.
]]

topics.become = [[
[[;white;]become (article) (attribute) name#id]
 Become a vessel.
 Articles (a, an, the) arg ignored.
 Appending "#id" with the appropriate vessel id allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.note = [[
[[;white;]note (string)]
 Changes the note on your parent vessel. Any text can be used, with spaces.
]]

topics.enter = [[
[[;white;]enter (article) (attribute) name#id]
 Enter another vessel.
 Articles (a, an, the) arg ignored.
 Appending "#id" with the appropriate vessel id allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

-- for name, text in pairs topics
--   topics[name] = text\sub 1, -2 -- remove trailing newline

topics.topics = ""
for name in pairs topics
  topics.topics ..= "[[;white;]#{name}], "
topics.topics = topics.topics\sub 1, -3

return topics
