function getOnePerson{
	Param (
		[Parameter(Mandatory=$true)][string]$usermeid
		)
	Get-ADUser -filter * -Server "mcccd.org"  -Properties EmployeeID,Created,whenChanged,Surname,GivenName,middleName,mccdLogonID,mccdEmployeeTypeDesc,mccdStudentID,Title,CanonicalName -SearchBase "OU=Employees,OU=MARICOPA,DC=mcccd,DC=org" | 
	Select-Object EmployeeID,Created,whenChanged,Surname,GivenName,middleName,mccdLogonID,mccdEmployeeTypeDesc,mccdStudentID,Title,CanonicalName | 
	Where-Object { $_.mccdLogonID -eq $usermeid } | 
	ConvertTo-Csv -NoTypeInformation | 
	% {$_.Replace('"','')} | 
	Out-File "C:\Users\VIN2164329\Documents\Git\getADuserGUI\output.csv" -Force
}

