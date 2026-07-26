# This file defines the base model class that ALL other models in your app inherit from.
# It acts as a shared parent — any common behavior for models can go here.

# ApplicationRecord inherits from ActiveRecord::Base, which is the core of Rails' database magic.
# It gives every model the ability to save, query, update, and delete database records.
class ApplicationRecord < ActiveRecord::Base
  # This tells Rails that this class is "abstract" — meaning it's never used directly to
  # talk to a database table. Only its children (like Task) do that.
  # It's like a blueprint for blueprints — it exists so other models can inherit from it.
  primary_abstract_class
end
