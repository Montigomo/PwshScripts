


# firast check network profile type need private

get-netconnectionprofile 

set-netconnectionprofile -name "NetorkName" -networkcategory "Public or Private"

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value 'Computer1,Computer2'