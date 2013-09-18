class Assembly < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  friendly_id :title, use: [:slugged, :history]
  attr_accessible :description, :image_id, :title, :youtube_id, :slug, :assembly_type, :assembly_inclusions_attributes, :price
  has_many :assembly_inclusions
  has_many :includables, through: :assembly_inclusions

  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :uploads
  has_many :enrollments, as: :enrollable

  scope :published, where(published: true)
  scope :projects, where(assembly_type: 'Project')

  accepts_nested_attributes_for :assembly_inclusions, allow_destroy: true

  ASSEMBLY_TYPE_SELECTION = ['Course', 'Project']
  INCLUDABLE_TYPE_SELECTION = ['Activity', 'Quiz']

  def ingredients
    assembly_inclusions.map(&:includable).map(&:ingredients).flatten.sort_by{|i|i.ingredient.title}.reject{|i| i.unit == 'recipe'}
  end

  def grouped_ingredients
    self.ingredients.group_by{|assembly_ingredient| [assembly_ingredient.ingredient, assembly_ingredient.note, assembly_ingredient.unit]}
  end

  def combined_ingredients
    self.grouped_ingredients.map{ |ingredient_group| [ingredient_group[0], ingredient_group[1].map(&:quantity).inject(:+), ingredient_group[1][0].unit] }
  end

  def required_equipment
    assembly_inclusions.map(&:includable).map(&:required_equipment).flatten.uniq{|e| e.title}.sort_by{ |e| e.title }
  end

  def optional_equipment
    optional = assembly_inclusions.map(&:includable).map(&:optional_equipment).flatten
    required_titles = assembly_inclusions.map(&:includable).map(&:required_equipment).flatten.map(&:title).map(&:downcase)
    displayable = []
    optional.each do |equipment|
      unless required_titles.include?(equipment.title.downcase)
        displayable << equipment
      end
    end
    displayable.uniq{|e| e.title}
  end

  def featured_image
    image_id
  end

  def faq
    title = self.slug + '-faq'
    Activity.find_by_slug(title)
  end

  def testimonials
    title = self.slug + '-testimonial'
    Page.find_by_slug(title)
  end
end
