# Overview Atomic red team subdirectory
ART is a purple team tool used to test common MITRE ATT&CK mapped threat actor TTPs
I begun using it for my SC200 cert labs, I created an Azure tenant and within that a VM to run ART and generate a load of telematary to better understand the adversarial mindset and practice threat hunting/ writing detections (using KQL)

I will add some of my KQL analytic rules and hunts used on the atomic red team atomics I use.
## Navigation
- AuditMode.ps1- this is a script to switch a windows endpoint into audit mode, preventing defender from stopping any threats, useful to carry out an entire attack chain and see what would have gotten through.
- T1059_.KQL This small KQL query can detect the TTP of using AutoIt to excute command line queries, download software without using powershell (Common technique to evade shell monitoring completely)

## technical details

I used an Azure VM, deployed atomic red team libary on to it, downloaded the ART execution framework, ran a plethora of tests, ranging from, initial access, privledge esc, reconnaisance to data exfiltration.
I then designed a range of sentinel and defender protections and utilized security copilot to close the gaps on my endpoints and catch more issues on a future run.
I then tested these rules out, and was able to utilize defenders reponse capabilties to stop the attack in motion, then sentinel/ XDR's capabilities to build playbooks to automatically quarintine related entities (namely devices in this instance).

