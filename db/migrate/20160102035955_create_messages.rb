class CreateMessages < ActiveRecord::Migration
    def change

        enable_extension 'hstore'

        create_table :messages do |t|
            t.references :user,     index: true
            t.references :feed,     index: true
            t.integer :message_type
            t.string :payload
            t.hstore :options
            t.datetime :sent_at
        end
    end
end
