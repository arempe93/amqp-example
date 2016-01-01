# == Schema Information
#
# Table name: devices
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uuid         :string
#  os           :integer
#  mobile       :boolean
#  user_agent   :string
#  amqp_queue   :string
#  token_hash   :string
#  last_request :datetime
#
# Indexes
#
#  index_devices_on_token_hash  (token_hash) UNIQUE
#  index_devices_on_user_id     (user_id)
#

FactoryGirl.define do
    factory :device do
        user nil
        uuid SecureRandom.uuid
        mobile false
        user_agent 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36'
        token_hash SecureRandom.urlsafe_base64(24)
    end
end
