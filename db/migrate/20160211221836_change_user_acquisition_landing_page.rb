class ChangeUserAcquisitionLandingPage < ActiveRecord::Migration[5.2]
  def change
    change_column :user_acquisitions, :landing_page, :text
  end
end
