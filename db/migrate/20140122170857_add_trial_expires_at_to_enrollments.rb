class AddTrialExpiresAtToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :trial_expires_at, :datetime
  end
end
