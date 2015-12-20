module API
    module Entities
        class Device < Grape::Entity

            expose :os, :amqp_queue

            expose :user, with: Entities::User

        end
    end
end
