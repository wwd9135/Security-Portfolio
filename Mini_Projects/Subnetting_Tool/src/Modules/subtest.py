import ipaddress
IP = ipaddress.IPv4Address
ip_network = ipaddress.IPv4Network

HostCount = 8000
startIp = IP("192.168.0.0")
dict1 = {
    "Marketing": 8000,
    "IT": 128,
    "HR": 8000
}

for HostName, HostCount in dict1.items():
    HostCount += 1
    BroadcastIp = IP(startIp) + HostCount
    NetworkIp = IP(startIp) + 1
    HostCount = HostCount - 1
    Last_Host = IP(NetworkIp) + HostCount
    startIp = IP(BroadcastIp) + 1 
    print(f"Subnet name: {HostName}, Network IP: {NetworkIp}, Broadcast IP: {BroadcastIp}, Last Usable IP: {Last_Host}")
# Append these 3 values to the dict for each subnet.
# of course with the right subnet name, do it in 

# print(IP("192.168.1.0") + 8000)