Function Remove-Ssh {
<#
  .SYNOPSIS
    remove stored ssh connections from config
    
  .DESCRIPTION
    remove stored ssh connections from config
    
  .PARAMETER id
    Id of the ssh connection to delete
    
  .EXAMPLE
    PS> Remove-Ssh -id 5
    # remove the stored ssh connection at position 5

  .EXAMPLE
    PS> Select-ssh -address "10.4." | Remove-Ssh
    # remove all stored ssh connections from config that have 10.4 in the address

  .INPUTS
    Id
    takes id by Property Name
    
  .OUTPUTS
    [pscustomobject]
    items that have been deleted
    
  .NOTES
    Author: pigeonlips
#>
  [CmdletBinding(
    PositionalBinding        = $True,
    ConfirmImpact            = 'high',
    SupportsShouldProcess
  )]

  Param (
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$True, Position=1, ValueFromPipelineByPropertyName = $true)]
    [String]$id

  )

  Begin {
    
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
    $SshModuleHosts          = @()
    $SshModuleHosts          = (SshModuleConfig).hosts | Sort Label
    $SshModuleDeletedHosts   = @()
  
  } Process {
    
    $SshModuleDeletedHosts  += $SshModuleHosts[$id]

  } End {
    
    $SshModuleDeletedHosts | Out-Host
    
    If ( $PSCmdlet.ShouldProcess( "Ssh Module Config" , "Delete these from" )  ) {
      
      $SshModuleConfig         = SshModuleConfig
      $SshModuleConfig.hosts   = $SshModuleHosts | ? { $_ -notin $SshModuleDeletedHosts }
      SshModuleConfig -SshConfig $SshModuleConfig
    
    }
    
  }
  
}