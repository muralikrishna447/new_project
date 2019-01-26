class AddIndexToUsersSlug < ActiveRecord::Migration
  def change

    # SELECT slug, COUNT(id) as CNT from users GROUP BY slug HAVING count(id) > 1;
    # slug          | cnt
    # ------------------------+-----
    # amy--720               |   2
    # carlos-alexandre-ayoub |   2
    # hannah-leger           |   2

    add_index :users, :slug, :unique => false # would love this to be unique but it's not

    # Do we fix the data manually? Maybe there is some other internal requirement to allow duplicates
  end
end
