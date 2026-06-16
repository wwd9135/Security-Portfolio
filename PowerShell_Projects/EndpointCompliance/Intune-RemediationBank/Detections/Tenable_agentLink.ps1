$AgentStatus = & "$env:programfiles\tenable\nessus agent\nessuscli.exe" agent status

if($AgentStatus -match "cloud.tenable.com:443")
    {
        Exit 0
    }
else
    {
        Exit 1
    }