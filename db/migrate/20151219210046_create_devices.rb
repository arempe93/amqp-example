class CreateDevices < ActiveRecord::Migration
    def change
        create_table :devices do |t|

            ## References
            t.references :user

            ## Device Info
            t.string :uuid
            t.integer :os
            t.boolean :mobile
            t.string :user_agent

            ## RMQ
            t.string :amqp_queue

            ## Tracking
            t.string :token_hash
            t.datetime :last_request
        end

        add_index :devices, :user_id,           unique: false
        add_index :devices, :token_hash,        unique: true
    end
end
