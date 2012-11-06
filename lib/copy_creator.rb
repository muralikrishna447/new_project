class CopyCreator
  def self.create
    copy_data = HashWithIndifferentAccess.new(YAML::load(File.open(File.join(Rails.root, "db", 'copy.yml'))))
    copy_data[:copy].each do |content|
      next if Copy.where(location: content[:location]).any?
      Copy.create!(location: content[:location], copy: content[:copy_content])
    end
  end
end
