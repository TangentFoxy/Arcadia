topics = {}

topics.basics = [[
Everything is a vessel. Vessels are named with a single word, and optionally, an attribute (i.e. "black cat" or "frog"). Even you are a vessel. Look around, interact with existing vessels, modify them, or make your own!

[[;white;]look]: See the vessels around you
[[;white;]enter <vessel>]: Enter a vessel (i.e. "enter the janitor's closet", "enter teacup")
[[;white;]leave]: Leave this vessel (the parent vessel, where you are)
[[;white;]create <vessel>]: Create a vessel (i.e. "create blue dog", "create a clipboard")
[[;white;]move <vessel> in|into <vessel>]: Move a vessel in another vessel (i.e. "move the dog into a test chamber")
[[;learn;]learn <topic>]: Learn more stuff ("learn about topics" gives a whole list!)

There is much more, consider "learn about movement" next! There are also "advanced" topics to look at, when you're ready.
]]

topics.movement = [[
This is mostly about moving YOU (your possessed vessel).

[[;white;]become <vessel>]: Possess another vessel (requires an account)
[[;white;]account create <name> <password> <email>]: Create an account, password and email are NOT required (you should use a password, or anyone can login as you!)
[[;white;]account login <name> <password>]: Login to an existing account (there are other account commands, "learn account", shows them all)
[[;white;]warp in|into <vessel>]: You can warp into any vessel at any time
[[;white;]warp <vessel> to <vessel>]: You can also warp vessels to each other (note the difference between to and into!)

Want to make and modify vessels? "learn about creation"
Or carry vessels with you? "learn about inventory"
]]

topics.creation = [[
The basics of creation and modification: creating, writing notes, and transformation.

[[;white;]create <vessel>]: Create a vessel (i.e. "create the orange", "create gunpowder")
[[;white;]note <text>]: Place, edit, or remove a note on the parent vessel
[[;white;]transform <vessel> into|to <vessel>]: Transform (or "rename") vessels (i.e. "transform the cup into a coffee mug")
[[;white;]transform <attribute> into|to <attribute>]: You can also transform attributes in bulk (i.e. "transform red to blue")
[[;white;]inspect <vessel>]: Shows a vessel's name, ID, and note (can inspect multiple vessels, or all vessels here)

More capabilities are coming soon: "learn about programming"
]]

topics.inventory = [[
[[;white;]inventory]: Show what you're holding
[[;white;]take <vessel>]: Take a vessel (from the parent vessel) and put it in your inventory
[[;white;]drop <vessel>]: Drop a vessel from your inventory (into the parent vessel)
]]

topics.advanced = [[
Advanced topics:
- naming: How vessel names and attributes work. Why a name should not be & or an integer.
- selection: How to type commands to select the correct vessel.
- structure: The structure of "reality" (What is a paradox? What is 'the parent vessel'?)
]]

topics.programming = [[
Not implemented yet!

[[;white;]use <vessel>]: Run a vessel's program
[[;white;]program <code>]: Add a program to the parent vessel
[[;white;]trigger <command>]: Add a custom command (i.e. "walk") that will trigger this vessel's program
[[;white;]passive <code>]: Add a program this vessel will run when in your inventory
[[;white;]cast <command> with <vessel>]: Run a vessel's program as if another vessel had triggered it
]]

-- account create|login|logout|delete|rename|password|email|show
-- become [vessel]
--
-- create [vessel]
-- transform [vessel|attribute] into|to [vessel|attribute]
-- note [text]
--
-- warp [vessel] in|into|to [vessel]
-- move [vessel] in|into [vessel]
-- enter [vessel]
-- leave
--
-- take [vessel]
-- drop [vessel]
--
-- look
-- inventory
-- inspect [vessel]
--
-- learn about|to [topic]

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
