module Eneroth
module LineUpAxes

  Sketchup.require "#{PLUGIN_DIR}/vendor/cmty-lib/entity"
  Sketchup.require "#{PLUGIN_DIR}/vendor/cmty-lib/component_definition"

  def self.make_unique(instances)
    # Groups are silently made unique.
    # Most users think of them as unique already, as editing them through the UI
    # makes them unique.
    instances.grep(Sketchup::Group, &:make_unique)

    # The user is asked whether components too should be made unique as this may
    # not be their intention.
    msg =
      "There are multiple instances of the same component in the "\
      "selection. To line up the axes of all of them they must be made unique.\n\n"\
      "Do you want to continue?"
    definitions = instances.map { |i| LEntity.definition(i) }.uniq
    unless instances.size == definitions.size || UI.messagebox(msg, MB_YESNO) == IDYES
      return false
    end
    instances.grep(Sketchup::ComponentInstance, &:make_unique)

    true
  end

  def self.line_up_axes
    model = Sketchup.active_model
    instances = model.selection.select { |i| LEntity.instance?(i) }
    model.start_operation("Line Up Axes", true)

    # Different instances of the same definition needs to be made unique to have
    # their axes adjusted individually (assuming there aren't perfectly
    # overlapping).
    unless make_unique(instances)
      model.abort_operation
      return
    end

    # In theory passing the inverse of an instance's transformation to place_axes
    # should line up its axes to those of the parent drawing context.
    #
    # However, when this parent drawing context is the active drawing context
    # SketchUp uses the global coordinate space rather than the local one,
    # meaning we have to actively take the so called "edit transformation" into
    # account.
    #
    # It is assumed all the selected instances are in the active drawing context.
    instances.each do |instance|
      LComponentDefinition.place_axes(
        LEntity.definition(instance),
        instance.transformation.inverse * model.edit_transform
      )
    end

    model.commit_operation
  end

  unless @loaded
    @loaded = true
    UI.menu("Plugins").add_item(EXTENSION.name) { line_up_axes }
  end

end
end
