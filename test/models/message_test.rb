# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  feed_id       :integer
#  message_type  :integer
#  payload       :string
#  options       :hstore
#  sent_at       :datetime
#  feed_sequence :integer
#
# Indexes
#
#  index_messages_on_feed_id  (feed_id)
#  index_messages_on_user_id  (user_id)
#

require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
