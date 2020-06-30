class ChangeUserAcquisitionReferrer < ActiveRecord::Migration[5.2]
  def change
    change_column :user_acquisitions, :referrer, :text
  end
end
