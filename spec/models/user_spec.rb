# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
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
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

describe User, type: :model do

    context '::create' do

        before do
            @user = User.create! name: 'Andrew', username: 'arempe93', password: 'Password1'
        end

        context 'should validate username' do

            it 'for presence' do

                @other = User.new name: 'Chris', password: 'password'

                expect(@other).to_not be_valid
                expect(@other.errors[:username]).to_not be_empty
            end

            it 'for uniqueness' do

                @other = User.new name: 'Chris', username: 'arempe93', password: 'password'

                expect(@other).to_not be_valid
                expect(@other.errors[:username]).to_not be_empty
            end

            it 'with formatting' do

                @other = User.new name: 'Chris', username: 'chris celi', password: 'password'

                expect(@other).to_not be_valid
                expect(@other.errors[:username]).to_not be_empty
            end
        end

        it 'should validate name' do

            @other = User.new name: 'Andrew R3mpe', username: 'andrew.rempe', password: 'Password1'

            expect(@other).to_not be_valid
            expect(@other.errors[:name]).to_not be_empty
        end

        it 'should declare an amqp exchange' do

            expect(AMQP::Factory.connection.exchange_exists?(@user.amqp_xchg)).to be_truthy
        end
    end

end
