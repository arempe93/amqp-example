class AddFeedSequenceToMessage < ActiveRecord::Migration
    def change
        add_column :messages, :feed_sequence, :integer, after: 'feed_id'
    end
end
