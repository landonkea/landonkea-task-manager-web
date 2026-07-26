# This file lets you define custom rules for how Rails transforms words between
# singular and plural forms. Rails uses these rules when generating things like
# table names, route helpers, and variable names.

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   `inflect.plural /^(ox)$/i, "\\1en"` tells Rails that "ox" becomes "oxen" (not "oxs").
#   inflect.plural /^(ox)$/i, "\\1en"
#   `inflect.singular /^(ox)en/i, "\\1"` tells Rails that "oxen" becomes "ox" (the reverse).
#   inflect.singular /^(ox)en/i, "\\1"
#   `inflect.irregular "person", "people"` tells Rails that "person" and "people" are related.
#   Rails normally just adds/removes "s", so irregular words need special handling.
#   inflect.irregular "person", "people"
#   `inflect.uncountable %w( fish sheep )` tells Rails these words are the same singular and plural.
#   "fish" stays "fish" whether you have one or many. Same with "sheep".
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   `inflect.acronym "RESTful"` tells Rails to keep "RESTful" in its original case
#   when converting between camelCase and snake_case. Without this, Rails might
#   turn "RESTful" into "rest_ful" or "REST_ful" in route names.
#   inflect.acronym "RESTful"
# end
