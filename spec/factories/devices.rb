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
#  index_devices_on_user_id     (user_id) UNIQUE
#

FactoryGirl.define do
  factory :device do
    
  end

end
