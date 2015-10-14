class Api::ActivityAssemblySerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :containing_assembly, :show_only_in_course

  def containing_assembly
    Api::AssemblyIndexSerializer.new(object.containing_course, root: false)
  end

end
