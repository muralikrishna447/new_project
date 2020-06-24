class AddTrialExpiresAtToEnrollments < ActiveRecord::Migration[5.2]
  def change
    add_column :enrollments, :trial_expires_at, :datetime
  end
end
