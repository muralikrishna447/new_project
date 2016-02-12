class ChangeUserAcquisitionLandingPage < ActiveRecord::Migration
  def change
    change_column :user_acquisitions, :landing_page, :text
  end
end
