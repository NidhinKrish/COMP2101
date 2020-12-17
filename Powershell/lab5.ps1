param ( [switch]$System, 
        [switch]$Disks,
        [switch]$Network
)

if ($System -eq $false -and $Disks -eq $false -and $Network -eq $false) {
        "SYSTEM INFO "
        "HARDWARE INFO :  "
        hardware_info | fl
        "OS INFO : "
        os_info | fl
        "CPU INFO : "
        processor_info | fl
        "RAM INFO : "
        memory_info| ft -AutoSize
        "DISK INFO : "
        disk_info | ft -AutoSize
        "NET INFO: "
        net_info | fl
    } 
else { 
    if ($System) {
        "HARDWARE INFO : "
        hardware_info | fl
        "OS INFO : "
        os_info | fl
        "CPU INFO : "
        processor_info | fl
        "RAM INFO : "
        memory_info| ft -AutoSize
    }
    if ($Disks) {
        "DISK INFO : "
        disk_info | ft -AutoSize
    }
    if ($Network) {
        "NETWORK INFO :"
        net_info | fl
    }

}