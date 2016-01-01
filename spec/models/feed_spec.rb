# == Schema Information
#
# Table name: feeds
#
#  id        :integer          not null, primary key
#  name      :string           not null
#  feed_type :integer          not null
#  amqp_xchg :string
#

require 'rails_helper'

RSpec.describe Feed, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
