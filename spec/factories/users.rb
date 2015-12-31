# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  amqp_xchg              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  name                   :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

FactoryGirl.define do
    factory :user do
        name Faker::Name.name
        username Faker::Internet.user_name
        email Faker::Internet.safe_email
        password SecureRandom.hex(8)
    end
end
