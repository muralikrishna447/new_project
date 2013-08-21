class PollSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :path

  def path
    poll_path(object)
  end
end