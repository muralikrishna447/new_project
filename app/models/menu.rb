class Menu < ApplicationRecord
  has_many :sub_menus, :foreign_key => :parent_id, class_name: 'Menu'
  belongs_to :parent_menu, :foreign_key => :parent_id, :class_name => 'Menu'

  scope :by_position, -> { order('position asc') }
  scope :main_menus, -> { where('parent_id is null').by_position }
  scope :child_menus, -> { where('parent_id is not null').by_position }
  scope :except_menu, -> menu_id { where('id !=?', menu_id) }
  scope :free, -> { where(is_free: true) }
  scope :studio, -> { where(is_studio: true) }
  scope :premium, -> { where(is_premium: true) }
  scope :not_logged, -> { where(is_not_logged: true) }


  def self.get_menus(type)
    mappings = { free: 'free_user_menu_cache', studio: 'studio_user_menu_cache',
                 premium: 'premium_user_menu_cache', not_logged: 'not_logged_user_menu_cache' }
    menu_list = send(type).by_position.group_by(&:parent_id)
    menu_list[0] =  menu_list.delete(nil)
    menu_list.sort.to_h
  end

end
