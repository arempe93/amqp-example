class CreateSubscriptions < ActiveRecord::Migration
    def change
        create_table :subscriptions do |t|
            t.references :user, index: true
            t.references :feed, index: true
        end
    end
end
