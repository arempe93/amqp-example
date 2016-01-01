# == Schema Information
#
# Table name: subscriptions
#
#  id      :integer          not null, primary key
#  user_id :integer
#  feed_id :integer
#
# Indexes
#
#  index_subscriptions_on_feed_id  (feed_id)
#  index_subscriptions_on_user_id  (user_id)
#

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
