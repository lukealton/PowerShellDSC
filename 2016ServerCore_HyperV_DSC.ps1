<#
Requirements:
The machine having the DSC applied to it requires remote management services and settings, even to apply to the localhost. Run enable-psremoting to determine if the settings are in place or to put them in place.

PowerShell Execution Policy setting needs to an appropriate level to run scripts.
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

Usage:
Based on DSC quick start guide:
https://docs.microsoft.com/en-us/powershell/dsc/quickstart

To apply a configuration to the local node:
Save the configuration as a PowerShell file

Compile the PowerShell file using dot notation
    example: . .\WorkstationDSC.ps1

Call the configuration in the compiled file by name, similar to using a PowerShell function
    example: LukeLaptop

Compiling and calling the configuration will create a folder with the name of the configuration, which will contain the configuration MOF file.

Begin applying the configuration by running Start-DscConfiguration and pointing at the created folder containing the MOF file, not the MOF itself.
    example: Start-DscConfiguration -Path .\LukeLaptop -wait -Verbose
 
#>
Configuration Server2016Core_HyperV_ClusterNode {

    param($Nodename)


    # Explicitly import built-in DSC resources.
    Import-DscResource -ModuleName 'PsDesiredStateConfiguration'#, 'xTimeZone', 'xComputerManagement'

    # The Node statement specifies which targets this configuration will be applied to.
    Node $Nodename {

        WindowsFeature HyperV
        {
            Ensure               = 'Present'
            Name                 = 'Hyper-V'
            IncludeAllSubFeature = $true
        }

        WindowsFeature FailoverClustering
        {
            Ensure               = 'Present'
            Name                 = 'Failover-Clustering'
            IncludeAllSubFeature = $true
        }

        WindowsFeature MultiPathIO
        {
            Ensure               = 'Present'
            Name                 = 'Multipath-IO'
            IncludeAllSubFeature = $true
        }

        WindowsFeature RSAT-Shielded-VM-Tools
        {
            Ensure               = 'Present'
            Name                 = 'RSAT-Shielded-VM-Tools'
            IncludeAllSubFeature = $true
        }

        WindowsFeature RSAT-Clustering-Powershell
        {
            Ensure               = 'Present'
            Name                 = 'RSAT-Clustering-Powershell'
            IncludeAllSubFeature = $true
        }

        WindowsFeature Hyper-V-PowerShell
        {
            Ensure               = 'Present'
            Name                 = 'Hyper-V-PowerShell'
            IncludeAllSubFeature = $true
        }

        WindowsFeature SMB1-FileSharing
        {
            Ensure               = 'Absent'
            Name                 = 'FS-SMB1'
        }

        File InboxFolder
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            DestinationPath = 'C:\Inbox' 
        }

<# Storage section. Important references:
iSCSI community DSC resource - https://github.com/PlagueHO/iSCSIDsc
Pure Storage documentation on iSCSI and MPIO configuration - https://support.purestorage.com/Solutions/Microsoft_Platform_Guide
#>

        Service iSCSIService
        {
            Name        = 'MSiSCSI'
            StartupType = 'Automatic'
            State       = 'Running'
        }
<#
        xTimeZone MountainTime
        {
            IsSingleInstance = 'Yes'
            TimeZone         = 'Mountain Standard Time'
        }
#>
        
    }
}