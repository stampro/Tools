function SysInfo{

    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        $targetPC
    )

    $Global:lpc = "$targetPC"

    if(!(Test-Connection -Cn $targetPC -BufferSize 16 -Count 1 -ea 0 -quiet))
     {
         write-host "Offline" -ForegroundColor Red -BackgroundColor Black
     }
  
    ELSE {

    clear-host


        foreach ($Computer in $targetPC) 
        {
            $computerSystem = get-wmiobject Win32_ComputerSystem -Computer $Computer
            $rDomain = $computerSystem.Domain
            $user = $computerSystem.UserName
            if ($rDomain -eq "wa.providence.org" -and $user -ne $null ){
                $uname = $user.Trim("PHSWA\")
            }
    
            if ($rDomain -eq "kmc.kadlec.org" -and $user -ne $null){
                $uname = $user.Trim("KADLEC\")
            }
            if($user){
            $fullUser = Get-ADUser -Filter {SamAccountName -like $uname} -Server $rDomain
            }
            if(!($user)){
                $user = "None"
            }
            $computerBIOS = get-wmiobject Win32_BIOS -Computer $Computer
            $computerOS = get-wmiobject Win32_OperatingSystem -Computer $Computer
            $computerCPU = get-wmiobject Win32_Processor -Computer $Computer
            $computerRAM = Get-WmiObject Win32_PhysicalMemory -Computer $computer
            $computerScreen = get-wmiobject Win32_VideoController -Computer $Computer
            $computerHDD = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter drivetype=3
            $computerMonitor = Get-WmiObject -Namespace root\wmi -Class wmiMonitorID -ComputerName $Computer
            $computerNetwork = (Get-WmiObject -query "select * from Win32_NetworkAdapterConfiguration where IPEnabled = $true" -ComputerName $Computer |
            Select-Object -Expand IPAddress | 
            Where-Object { ([Net.IPAddress]$_).AddressFamily -eq "InterNetwork" } )
            $computerPrinter = Get-WmiObject Win32_Printer -Computer $Computer 


                write-host "System Information for: " $computerSystem.Name -ForegroundColor Green
                "-------------------------------------------------------"
        
                write-host "Domain:" $computerSystem.Domain -ForegroundColor Cyan
                "Manufacturer: " + $computerSystem.Manufacturer
                "Model: " + $computerSystem.Model
                "Serial Number: " + $computerBIOS.SerialNumber
                "CPU: " + $computerCPU.Name
                "Operating System: " + $computerOS.caption
   
            Foreach ($hdd in $computerHDD) {
               If($hdd.Size/1GB -ge 50) {
                "HDD Capacity: "  + "{0:N2}" -f ($hdd.Size/1GB) + "GB"
                "HDD Space: " + "{0:P2}" -f ($hdd.FreeSpace/$hdd.Size) + " Free (" + "{0:N2}" -f ($hdd.FreeSpace/1GB) + "GB)"
                  }
              }

                "RAM: " + "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB" 
                $memory = $computerRAM 
   #             "{0} sticks:" -f $memory.count

   #         Foreach ($stick in $memory) {
   #             $cap=$stick.capacity/1GB
   #             Write-Host "{0}" -f $cap + "GB"
   #           }

                "User logged In: " + $user
                Write-Host "User Full Name: " -NoNewline
                Write-Host "$($fullUser.GivenName) $($fullUser.Surname)" -ForegroundColor Green
                "Last Reboot: " + $computerOS.ConvertToDateTime($computerOS.LastBootUpTime)
                "IP: " + $Computernetwork

           $monitorInfo = @()
            Foreach ($monitor in $computerMonitor) {
                $mon = New-Object PSObject
                $name = $null
                $monitor.UserFriendlyName | foreach {$name += [char]$_}
                $mon | Add-Member NoteProperty "Monitor Models" $name
                $monitorInfo += $mon  }

                 Write-Output $monitorInfo        
            }

            "--------------"
	  #  Write-Host "Printers " -ForegroundColor Blue
      #      $computerPrinter.Name



    }
};Set-Alias sys SysInfo -Description "Get System Info from remote PC."

Export-ModuleMember -Function SysInfo -Alias sys