module Enums
    class MessageType < EnumerateIt::Base

        ## Enumeration
        associate_values(
            chat: [1, 'chat'],
            event: [2, 'event']
        )
    end
end
