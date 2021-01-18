class Menu < ApplicationRecord
  CACHE_KEYS =  { free: 'free_user_menu_cache',
                  studio: 'studio_user_menu_cache',
                  premium: 'premium_user_menu_cache',
                  not_logged: 'not_logged_user_menu_cache',
                  admin: 'admin_user_menu_cache' }.freeze

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
  scope :by_parent, -> menu_id { where(parent_id: menu_id).by_position }
  scope :admin, -> { where("is_free = :val OR is_studio = :val OR is_premium = :val OR is_not_logged = :val", val: true) }
  scope :json_response, -> { select(:id, :name, :url, :parent_id, :position).as_json }


  before_create do
    self.position = if parent_id.present?
                      Menu.by_parent(parent_id).last&.position.to_i + 1
                    else
                      Menu.main_menus.last&.position.to_i + 1
                    end
  end

  after_commit do
    CACHE_KEYS.values.each do |cache_name|
      Rails.cache.delete(cache_name)
    end
  end

  def self.get_preview_menus
    menu_list = admin.by_position.group_by(&:parent_id)
    menu_list[0] =  menu_list.delete(nil)
    menu_list.sort.to_h
  end

  def self.get_menus(permission)
    cache_key = CACHE_KEYS[permission]

    return nil unless cache_key.present?

    Rails.cache.fetch(cache_key, expires_in: 7.days) do
      menu_groups = Hash.new { |h, k| h[k] = [] }
      send(permission).by_position.json_response.each {|menu| menu_groups[menu['parent_id'] || 0] << menu}
      menu_groups.sort.to_h
    end
  end

  def is_parent_menu?
    parent_id.blank?
  end

end
