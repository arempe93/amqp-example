module Enums
    class DeviceOS < EnumerateIt::Base

        ## Enumeration
        associate_values(
            windows: [1, 'Windows'],
            mac: [2, 'Macintosh OSX'],
            linux: [3, 'Linux'],
            android: [4, 'Android'],
            ios: [5, 'iOS'],
            unknown: [6, 'Unknown']
        )

        ## Class Methods
        def self.from_user_agent(user_agent)

            case user_agent

                when /windows/i
                    return DeviceOS::WINDOWS

                when /(macintosh)|(mac_powerpc)/i
                    return DeviceOS::MAC

                when /(linux)|(x11)/i
                    return DeviceOS::LINUX

                when /android/i
                    return DeviceOS::ANDROID

                when /(iphone)|(ipad)|(ipod)/i
                    return DeviceOS::IOS

                else return DeviceOS::UNKNOWN
            end
        end
    end
end
