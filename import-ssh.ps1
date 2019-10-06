Function Import-Ssh {
<#
  .SYNOPSIS
    imports any ssh connections from putty
    
  .DESCRIPTION
    imports any ssh connections from putty
    
  .PARAMETER Filter
    
  .EXAMPLE
    PS> Import-Ssh
    #

  .INPUTS
    None
    
  .OUTPUTS
    None
    
  .NOTES
    Author: pigeonlips
#>
  [CmdletBinding(
    PositionalBinding                  = $False,
    ConfirmImpact                      = 'high',
    SupportsShouldProcess
  )]

  Param (
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, Position=0, ValueFromPipeline = $False)]
    [String]$Filter = '.*'
    
  )

  Begin {
    
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
    

  } Process {
    
    If (Test-Path "HKCU:\SOFTWARE\SimonTatham\PuTTY\Sessions\" ) {
      
      Write-Verbose "[$($MyInvocation.MyCommand.Name)] Process ~ Found Putty in registry "

      Get-ChildItem HKCU:\SOFTWARE\SimonTatham\PuTTY\Sessions\ | ForEach-Object {
        
         $putty_props     = Get-ItemProperty $_.PSPath
         $ssh_label       = $($_.PSChildName -replace ('%20' , ' '))
         $ssh_address     = @()
         
         If ($putty_props.Username)   { $ssh_address += "$($putty_props.Username)@"   }
         If ($putty_props.HostName)   { $ssh_address += "$($putty_props.HostName)"    }
         If ($putty_props.PortNumber) { $ssh_port     = "$($putty_props.PortNumber)"  }

         If (-not $ssh_address)  {
         
           Write-Verbose "[$($MyInvocation.MyCommand.Name)] Process ~ Skipping ""$ssh_label"" as there is no address ! "
           Return
         
         }
         
         Write-Verbose "[$($MyInvocation.MyCommand.Name)] Process ~ Importing ""$($ssh_address -join(''))"" as ""$ssh_label"" "
         
         If ( $ssh_label -in ((SshModuleConfig).hosts.label) ) {
         
           Write-Warning "$ssh_label is already saved in ssh module config. Replace ..."
           Write-Warning "$ssh_label > $( (SshModuleConfig).hosts | ? { $_.label -eq $ssh_label} | select -ExpandProperty Address)"
           Write-Warning "   with "
           Write-Warning "$ssh_label < $ssh_address"

           If (  -not $PSCmdlet.ShouldProcess( "$($ssh_address -join(''))" , "Save $ssh_label" )  ) {
   
             Return
   
           } # end if should process
       
         } # if already in config
         
         Write-Verbose "[$($MyInvocation.MyCommand.Name)] Process ~ adding $($ssh_address -join(''))"
         AddSshAddress               -Address $($ssh_address -join('')) -Label $ssh_label -Port $ssh_port

      } # end for each putty saved session
      
    } # end if putty in registry
    
  } End {
    

  }
  
}