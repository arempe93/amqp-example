module Enums
    class DeviceOS < EnumerateIt::Base
        associate_values(
            windows: [1, 'Windows'],
            mac: [2, 'Macintosh OSX'],
            linux: [3, 'Linux'],
            android: [4, 'Android'],
            ios: [5, 'iOS']
        )
    end
end
