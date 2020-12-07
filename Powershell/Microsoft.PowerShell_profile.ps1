function welcome {
write-output "Welcome to planet $env:computername Overlord $env:username"
$now = get-date -format 'HH:MM tt on dddd'
write-output "It is $now."
}
welcome

new-item -path alias:np -value notepad |out-null


function get-cpuinfo {
get-ciminstance cim_processor | Select-Object Manufacturer,Name,Caption,currentclockspeed,maxclockspeed,numberofcores
}
get-cpuinfo

function get-mydisks{
         Get-WmiObject win32_diskdrive | foreach {
		New-Object -TypeName psobject -Property @{
    			Model=$_.model;
                        Name=$_.Name;
			Manufacturer=$_.manufacturer;
    			Serial_Number=$_.serialnumber;
    			Firmware_Revision=$_.firmwarerevision;
    			Size=$_.size;
	}
}
}
get-mydisks