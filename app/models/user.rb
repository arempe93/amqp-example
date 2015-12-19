class User < ActiveRecord::Base

    ## Devise
    devise :database_authenticatable, :registerable,
        :recoverable, :trackable, :validatable
end
