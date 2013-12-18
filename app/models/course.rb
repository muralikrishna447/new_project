class Course < ActiveRecord::Base
#   extend FriendlyId
#   include RankedModel
#   include PublishableModel

#   friendly_id :title, use: :slugged

#   ranks :course_order

#   scope :ordered, rank(:course_order)

#   attr_accessible :description, :title, :short_description, :slug, :course_order, :image_id, :additional_script, :youtube_id

#   has_many :inclusions, :dependent => :destroy, :order => 'activity_order ASC'
#   has_many :activities, :through => :inclusions, :order => 'inclusions.activity_order ASC'
#   # has_many :enrollments
#   has_many :enrollments, as: :enrollable
#   has_many :users, through: :enrollments
#   has_many :uploads

#   def update_activities(activity_hierarchy)
#     activities.delete_all
#     activity_hierarchy.each do |activity_info|
#       activity_id, nesting_level, title = activity_info[0], activity_info[1], activity_info[2]
#       logger.debug nesting_level if activity_id == 500
#       if activity_id.present?
#         begin
#           activity = Activity.find(activity_id)
#         rescue
#           activity = Activity.create()
#           activity.title = title
#           activity.save!
#           activity_id = activity.id
#         end
#         self.activities << activity
#         self.save!
#         incl = inclusions.find_by_activity_id(activity_id)
#         incl.update_attributes(nesting_level: nesting_level)
#       end
#     end
#     self
#   end

#   def first_published_activity
#     inclusion = inclusions.find {|i| i.activity.published? && (i.nesting_level != 0)}
#     inclusion.activity
#   end

#   def next_published_activity(activity, inclusion_list = inclusions)
#     # I'm sure there is a clever one liner for this, writing on an airplane with no doc access
#     found_pivot = false
#     inclusion_list.each do |incl|
#       return incl.activity if found_pivot && incl.activity.published? && (incl.nesting_level != 0)
#       found_pivot = true if incl.activity == activity
#     end
#     nil
#   end

#   def prev_published_activity(activity)
#     next_published_activity(activity, inclusions.reverse)
#   end

#   def activity_modules
#     inclusions.select{|i| i.nesting_level == 0}.map{|i| i.activity}
#   end

#   def current_module(activity)
#     # Returns the module the current activity belongs to
#     current_inclusion = inclusions.includes(:activity).select{|i| i.activity.id == activity.id}.first
#     current_inclusion_index = inclusions.index(current_inclusion)
#     current_parent_module = nil
#     i = current_inclusion_index
#     until current_parent_module
#       i-=1
#       if inclusions[i].nesting_level == 0
#         current_parent_module = inclusions[i]
#       end
#     end
#     return current_parent_module
#   end

#   def parent_inclusion(inclusion)
#     current_nesting_level = inclusion.nesting_level
#     parent_nesting_level = current_nesting_level == 0 ? nil : current_nesting_level - 1
#     index = inclusions.index(inclusion)
#     parent = nil
#     if parent_nesting_level
#       until parent
#         index -=1
#         parent = inclusions[index].nesting_level == parent_nesting_level ? inclusions[index] : nil
#       end
#     end
#     parent
#   end

#   def child_inclusions(inclusion)
#     current_nesting_level = inclusion.nesting_level
#     child_nesting_level = current_nesting_level + 1
#     index = inclusions.index(inclusion)
#     children = []
#     next_object = next_inclusion(inclusion)
#     while next_object && next_object.nesting_level > current_nesting_level
#       index +=1
#       if next_object.nesting_level == child_nesting_level
#         children << next_object
#       end
#       next_object = next_inclusion(next_object)
#     end
#     children
#   end

#   def next_inclusion(inclusion)
#     index = inclusions.index(inclusion)
#     inclusions[index + 1]
#   end

#   def viewable_activities
#     # inclusions.where('nesting_level <> ?', 0).joins(:activity).where('inclusions.activity.published = ?', true)
#     activities.published - activity_modules
#   end

#   def featured_image
#     self.image_id || self.first_published_activity.featured_image || 'http://www.placehold.it/320x180/f2f2f2/f2f2f2'
#   end

#   def assignment_activities
#     activities.joins(:assignments).map(&:child_activities).flatten.uniq
#   end

#   #### Spherification Course ####
#   SPHERIFICATION_CREATIVE = {
#     copy: "The Modernist Pantry Creative Sphere Magic Kit includes the technical ingredients you'll need to complete the ChefSteps reverse and direct spherification modules. It has most of the tools as well, except for a high-accuracy scale and the mold needed for frozen-reverse spherification.",
#     price: '39',
#     variant_id: 311070543,
#     equipment: ['Syringe', 'Spherification Straining Spoon', '25 g Sphere Magic', '50 g Sodium Citrate', '50 g Calcium Gluconate', '50 g Calcium Chloride', '50 g Xanthan Gum']
#   }

#   SPHERIFICATION_ENTHUSIAST = {
#     copy: "The Modernist Pantry Enthusiast Sphere Magic Kit includes all of the technical ingredients and tools you'll need to complete the entire ChefSteps spherification course. It adds a high-accuracy scale (capable of weighing 1/10th of a gram) and a high-quality silicon mold used for frozen-reverse spherification.",
#     price: '79',
#     variant_id: 311979727,
#     equipment: ['Syringe', 'Spherification Straining Spoon', '25 g Sphere Magic', '50 g Sodium Citrate', '50 g Calcium Gluconate', '50 g Calcium Chloride', '50 g Xanthan Gum', 'High-Precision Scale', 'Frozen Reverse Spherification Mold']
#   }

#   SPHERIFICATION_PROFESSIONAL = {
#     copy: "The Modernist Pantry Professional Sphere Magic Kit includes everything in the Enthusiast Kit, plus a professional caviar dosing tray used for direct spherification. This hard to find tool makes it easy to quickly turn any liquid into small spheres bursting with flavor. This kit includes all of the tools featured in ChefSteps spherification course.",
#     price: '119',
#     variant_id: 311979875,
#     equipment: ['Syringe', 'Spherification Straining Spoon', '25 g Sphere Magic', '50 g SHMP', '50 g Calcium Gluconate', '50 g Calcium Chloride', '50 g Xanthan Gum', 'High-Precision Scale', 'Frozen Reverse Spherification Mold', 'Rapid Caviar Maker']
#   }


# #### Science of Poutine Course ####

#   SVS_DEMI = {
#     copy: "A compact version of the original SousVide Supreme that features all of the benefits of the original appliance in a smaller footprint. This unit has a 2.3 gallon / 8.7 liter capacity sealed reservoir with a nonstick coating for easier cleaning. Available in red or black finish.",
#     price: '329',
#     variant_id: 291719279
#   }

#   SVS = {
#     copy: "The original SousVide supreme appliance has a 3 gallon / 11.3 liter capacity sealer reservoir that is easily cleaned. The appliance is insulated for fast preheating and energy efficiency. The controls are simple and intuitive to use. This appliance comes with a stainless steel rack that efficiently organizes individual cooking bags to speed cooking. Available in  a brushed stainless steel finish.",
#     price: '429',
#     variant_id: 286923754
#   }

#   def forum_link
#     case self.id
#     when 8
#       forum_link = 'http://forum.chefsteps.com/categories/spherification-course-questions'
#     when 10
#       forum_link = 'http://forum.chefsteps.com/categories/science-of-poutine-course-questions'
#     else
#       forum_link = 'http://forum.chefsteps.com/discussions'
#     end
#   end

end

