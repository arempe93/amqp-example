module Enums
    class FeedType < EnumerateIt::Base

        ## Enumeration
        associate_values(
            private: [1, 'Private'],
            group: [2, 'Group']
        )
    end
end
