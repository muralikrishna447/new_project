class Equipment < ActiveRecord::Base
  include CaseInsensitiveTitle

  has_many :activity_equipment, inverse_of: :equipment, dependent: :destroy
  has_many :activities, through: :activity_equipment, inverse_of: :equipment

  attr_accessible :title, :product_url

  scope :search_title, -> title { where('title iLIKE ?', '%' + title + '%') }

  def self.titles
    # Switching this because
    # all.map(&:title)
    #=> Equipment Load (3.4ms)  SELECT "equipment".* FROM "equipment"
    pluck(:title)
    #=> SQL (0.7ms)  SELECT "equipment"."title" FROM "equipment"
  end

  def replace_activity_equipment_with(new_equipment)
    self.activity_equipment.each do|ae|
      ae.equipment = new_equipment
      ae.save
    end
    self.reload
  end

  # Replace activity records to merge equipment records together
  def merge(group)
    # Just to be sure
    group.delete(self)

    group.each do |equipment|
      equipment.replace_activity_equipment_with(self)
      if (equipment.activities.count == 0)
        equipment.destroy
      else
        raise "Unexpected dependencies remain for #{equipment.title} (id: #{equipment.id})... not deleting"
      end
    end

    self.reload

  end

end

