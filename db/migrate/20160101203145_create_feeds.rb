class CreateFeeds < ActiveRecord::Migration
    def change
        create_table :feeds do |t|
            t.string :name,         null: false
            t.integer :feed_type,   null: false
            t.string :amqp_xchg
        end
    end
end
