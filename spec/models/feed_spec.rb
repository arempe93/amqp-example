# == Schema Information
#
# Table name: feeds
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  feed_type  :integer          not null
#  amqp_xchg  :string
#  creator_id :integer
#
# Indexes
#
#  index_feeds_on_creator_id  (creator_id)
#  index_feeds_on_name        (name) UNIQUE
#

require 'rails_helper'

RSpec.describe Feed, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
