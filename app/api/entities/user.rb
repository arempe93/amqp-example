module API
    module Entities
        class User < Grape::Entity

            expose :id, :username, :name

        end
    end
end
