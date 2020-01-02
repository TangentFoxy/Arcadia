import Vessels from require "models"
import create_table, types, add_column from require "lapis.db.schema"

{
  [1]: =>
    create_table "users", {
      { "id", types.serial primary_key: true }
      { "name", types.varchar unique: true }
      { "email", types.varchar null: true }
      { "digest", types.text null: true }
      { "vessel_id", types.foreign_key null: true }
    }
    create_table "vessels", {
      { "id", types.serial primary_key: true }
      { "name", types.varchar }
      { "attribute", types.varchar }
      { "note", types.text }
      { "parent", types.foreign_key }
    }
    -- a library and a ghost
    Vessels\create {
      name: "library"
      attribute: ""
      note: "Welcome to the library. You can edit this message with the 'note' command. This is a shared space, so please try to be nice. <3"
      parent: 1
    }
    Vessels\create {
      name: "ghost"
      attribute: ""
      note: "This is the ghost that all new users initially possess."
      parent: 1
    }
}
