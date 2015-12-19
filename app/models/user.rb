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
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base

    ## Devise
    devise :database_authenticatable, :registerable,
        :recoverable, :trackable, :validatable

    ## Callbacks
    before_create :create_xhcg

    ## Validations
    validates :email, uniqueness: { case_sensitive: false }

    ## Relationships
    has_many :devices

    ## Private Methods
    private
    def create_xhcg

        # generate exchange name
        self.amqp_xchg = "xchg.user.#{self.id}"

        begin

            # create in rmq
            AMQP::Factory.create_exchange self.amqp_xchg, durable: true

        rescue => e

            # log error
            Rails.logger.error "#<User id:#{self.id}>.create_xchg raised => '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

            # bubble up call stack
            raise

        else

            # continue creation
            true
        end
    end
end
