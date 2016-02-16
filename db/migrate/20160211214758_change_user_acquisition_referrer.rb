class ChangeUserAcquisitionReferrer < ActiveRecord::Migration
  def change
    change_column :user_acquisitions, :referrer, :text
  end
end
