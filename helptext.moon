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

-- topics.message

topics.create = [[
[[;white;]create (article) (attribute) name]
 Creates a vessel.
 Articles (a, an, the) are ignored.
 Attributes are usually displayed with a vessel's name.
 Vessels must be named, names cannot have spaces. It is recommended that you do not include "#" in vessel names, as this can cause complications with other commands.
]]

topics.become = [[
[[;white;]become (article) (attribute) name#id]
 Become a vessel.
 Articles (a, an, the) arg ignored.
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.transform = [[
[[;white;]transform] (article) (attribute|name#id) preposition (article) (attribute|name)
 Transforms one or more vessels' names or attributes.
 Articles (a, an, the) are ignored.
 Valid prepositions: in, into, to
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.note = [[
[[;white;]note (string)]
 Changes the note on your parent vessel. Any text can be used, with spaces.
]]

topics.warp = [[
[[;white;]warp ((article) (attribute) name#id) preposition (article) (attribute) name#id]
 Warp your possessed vessel or a specific vessel in/into/to any destination vessel.
 Articles (a, an, the) are ignored.
 Valid prepositions: in, into, to
]]

topics.move = [[
[[;white;]move (article) (attribute) name#id preposition (article) (attribute) name#id]
 Move a specific vessel into an adjacent vessel.
 Articles (a, an, the) are ignored.
 Valid prepositions: in, into, to
]]

topics.enter = [[
[[;white;]enter (article) (attribute) name#id]
 Enter another vessel.
 Articles (a, an, the) arg ignored.
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.leave = [[
[[;white;]leave]
 Leave the current parent vessel.
]]

topics.take = [[
[[;white;]take (article) (attribute) name#id]
 Pick up a vessel. (It is moved into your current vessel.)
 Articles (a, an, the) arg ignored.
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.drop = [[
[[;white;]drop (article) (attribute) name#id]
 Drop a vessel (inside the currently possessed vessel.)
 Articles (a, an, the) arg ignored.
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.look = [[
[[;white;]look ((preposition) (article) (attribute) name#id)]
 Look at your parent vessel and what is inside it, or look inside a specific vessel.
 Articles (a, an, the) are ignored.
 Valid prepositions: in, into, to
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.inventory = [[
[[;white;]inventory]
 List what vessels you are carrying.
]]

topics.inspect = [[
[[;white;]insepct (article) (attribute) name#id]
 Inspect the ID of one or more vessels. In the future, this will show more information.
 Articles (a, an, the) are ignored.
 Appending "#" and the appropriate vessel id to the name allows you to specify a specific vessel even if two exist with the same name and attribute.
]]

topics.learn = [[
[[;white;]learn ("about"|"to") string]
 Learn about a command or topic. You can view a list of topics by running [[;white;]learn topics].
]]

for name, text in pairs topics
  topics[name] = text\sub 1, -2 -- remove trailing newline

topics.topics = {}
for name in pairs topics
  table.insert topics.topics, "[[;white;]#{name}]"
table.sort topics.topics
topics.topics = table.concat topics.topics, ", "

return topics
