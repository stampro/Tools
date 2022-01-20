# Script takes in a computer name and remotely forces user to log off. 
#
# Valid arguments for Win32Shutdown method:
#
# 0 Log Off
# 0 + 4 Forced Log Off
# 2 Reboot
# 2 + 4 Forced Reboot



$comp = read-host "Computer Name"
(gwmi win32_operatingsystem -ComputerName $comp).Win32Shutdown(0 + 4)