class AddIdentityToUser < ActiveRecord::Migration
    def change

        add_column :users, :username, :string
        add_column :users, :name, :string

        add_index :users, :username, unique: true
    end
end
