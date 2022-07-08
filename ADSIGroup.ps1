$servers = Get-content -Path C:\Temp\computers.txt
ForEach ($Computer in $servers) {
    $Computer = [ADSI]"WinNT://$Computer"
    $Groups = $Computer.psbase.Children | Where { $_.psbase.schemaClassName -eq "group" }

    ForEach ($Group In $Groups) {
        "Group: " + $Group.Name
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement -ErrorAction 'Stop' -ErrorVariable ErrorBeginAddType
        $ctype = [System.DirectoryServices.AccountManagement.ContextType]::Machine
        $context = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ctype, $computer
        $idtype = [System.DirectoryServices.AccountManagement.IdentityType]::SamAccountName
        $group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($context, $idtype, $GroupName)
        $group.Members | Select-Object *, @{ Label = 'Server'; Expression = { $computer } }, @{ Label = 'Domain'; Expression = { $_.Context.Name } }
        $Members = @($Group.psbase.Invoke("Members"))
        ForEach ($Member In $Members) {
            $Class = $Member.GetType().InvokeMember("Class", 'GetProperty', $Null, $Member, $Null)
            $Name = $Member.GetType().InvokeMember("Name", 'GetProperty', $Null, $Member, $Null)
            "-- Member: $Name ($Class)"
        }
    }
}
