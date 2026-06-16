import ipaddress

class subnet:
    def __init__(self):
        pass

    def SubnetCreator(self, SubnetDict: dict):
        # Ensures each subnet has enough hosts, rounds up to nearest valid subnet size.
        ValidHostCounts = [2,6,14,30,62,126,254,510,1022,2046,4094,8190,16382,32766,65534]
        FinishedDict = {}
        for subnet_name, host_count in SubnetDict.items():
            for valid_count in ValidHostCounts:
                if host_count <= valid_count:
                    FinishedDict[subnet_name] = valid_count
                    break

        return FinishedDict

    def IP_Adddressing(self, dict1: dict):
        FinalDict = []
        IP = ipaddress.IPv4Address
        startIp = IP("192.168.0.0")

        for HostName, HostCount in dict1.items():
            HostCount += 1
            BroadcastIp = IP(startIp) + HostCount
            NetworkIp = IP(startIp) + 1
            HostCount = HostCount - 1
            Last_Host = IP(NetworkIp) + HostCount
            startIp = IP(BroadcastIp) + 1 

            NetworkIp = str(NetworkIp)
            BroadcastIp = str(BroadcastIp)
            Last_Host = str(Last_Host)
            BroadcastIp = BroadcastIp.strip("IPV4Address(").strip(")")
            Last_Host = Last_Host.strip("IPV4Address(").strip(")")
            NetworkIp = NetworkIp.strip("IPV4Address(").strip(")")

            FinalDict.append({
            "Subnet Name": HostName,
            "Total Host Count": HostCount, 
            "Network address": NetworkIp,
            "Broadcast address": BroadcastIp,
            "Last usable host": Last_Host,
            "Subnet mask": "255.255.0.0"
            })
        for i in FinalDict:
            
            print(f"-------------------------\n\033[1;50mSubnet: {i['Subnet Name']}\033[0m\n-------------------------")
     
            num = 0 
            for a,t in i.items():
                if num < 1:
                    num += 1
                else:
                    print(f"{a}: {t}")
        print("-------------------------\n\033[1;92mSubnetting complete\033[0m  \n-------------------------")

        return FinalDict[0]
                