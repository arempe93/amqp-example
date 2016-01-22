class AddCreatorToFeed < ActiveRecord::Migration
	def change
		add_column :feeds, :creator_id, :integer
		add_index :feeds, [:creator_id], unique: false
	end
end
