require 'extensions.rb'

# Eneroth Extensions
module Eneroth

# Eneroth Line Up Axes
module LineUpAxes

  path = __FILE__
  path.force_encoding("UTF-8") if path.respond_to?(:force_encoding)

  PLUGIN_ID = File.basename(path, ".*")
  PLUGIN_DIR = File.join(File.dirname(path), PLUGIN_ID)

  EXTENSION = SketchupExtension.new(
    "Eneroth Line Up Axes",
    File.join(PLUGIN_DIR, "main")
  )
  EXTENSION.creator     = "Eneroth3"
  EXTENSION.description =
    "Line up group or component axes with that of parent drawing context."
  EXTENSION.version     = "1.0.0"
  EXTENSION.copyright   = "2018, #{EXTENSION.creator}"
  Sketchup.register_extension(EXTENSION, true)

end
end
