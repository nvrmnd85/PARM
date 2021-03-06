################### DESCRIPTION ###########
## DEVELOPER: AARON JACKSON
## DATE: 08/04/2015
## DESC: This script will create SQL insert scripts
################## END DESCRIPTION ########

## TEST
# .\Bulk_Copy_Environment.ps1 -Server_Env "POC"
##

################ VARIABLES #################
Param (
    
    [String]
    [ValidateSet("POC")]
    [Parameter(Mandatory = $true)] 
    $Server_Env
)
################ END VARIABLES #################


################ SCRIPT ########################

    Clear-Host
    
    Write-Host "Script Starting"

    Switch ($Server_Env)
    {
        "POC" {
                $server = "cerberus.bct.local"
                $dbnames = @("PARM_DW")
                #$schema = "GenWeb"
              }
    }

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null

    $SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist $server

    foreach ($dbname in $dbnames)
    {
        Write-Host "Enumerating $dbname"
    
        $db = $SMOserver.databases[$dbname]
     
        $Objects = $db.Tables #| Where-object {$_.schema -eq $schema}  
     
        foreach ($ScriptThis in $Objects | where {!($_.IsSystemObject)}) 
        {            
                                    # this is essentially like starting a new powershell session, the absolute script path needs to be used
           Start-Job -ScriptBlock {& C:\Users\Aaron.BCT\Sync\Barking_Cat\PARM\PARM\Utilities\Copy_SQL_Table.ps1 -SrcServer "NVRMND-LAPTOP" -SrcDatabase "PARM_DW" -SrcTable @args -DestServer "cerberus.bct.local" -Truncate} -ArgumentList "$ScriptThis" | Out-Null
           Write-Host "Loading Table $ScriptThis"
            
        }
        
        Write-Host "Data load in progress.."
        
        While ($(Get-Job -State Running).count -gt 0){
                   
            #waiiiit for the jobs to finish
        
        }
        
        Get-Job | Receive-Job | Select-Object * -ExcludeProperty RunspaceId | out-gridview
        #return the job output to console
        
    }
    
    Write-Host "Script Complete"
   