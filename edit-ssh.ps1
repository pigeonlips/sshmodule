Function Edit-Ssh {
<#
  .SYNOPSIS
    edit a stored ssh connections from config
    
  .DESCRIPTION
    edit a stored ssh connections from config
    
  .PARAMETER id
    Id of the ssh connection to delete

  .PARAMETER label
    Label to use for the stored ssh connection
    
  .PARAMETER address
    Address to use for the stored ssh connection
    
  .PARAMETER port
    Port to use for the stored ssh connection
    
  .EXAMPLE
    PS> Edit-Ssh -id 5 -label "new host name"
    # change the label of stored ssh connection at position 5 to "new host name"

  .EXAMPLE
    PS> Select-Ssh -port 100 | Edit-Ssh -port 22
    # Change all stored ssh connections with a port of 100 to have a port of 22

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
    PositionalBinding                  = $True
  )]

  Param (
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$True, Position=1, ValueFromPipelineByPropertyName = $true)]
    [String]$id,
    
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, ValueFromPipelineByPropertyName = $False)]
    [String]$label,

    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, ValueFromPipelineByPropertyName = $False)]
    [String]$address,

    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, ValueFromPipelineByPropertyName = $False)]
    [String]$port,
    
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, ValueFromPipelineByPropertyName = $False)]
    [String]$BackColor,

    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, ValueFromPipelineByPropertyName = $False)]
    [String]$ForeColor
  )

  Begin {
    
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
    $SshModuleHosts = (SshModuleConfig).hosts | Sort Label

  } Process {
    
    If ($PSBoundParameters.label)        { $SshModuleHosts[$id].label      =  $PSBoundParameters.label     }
    If ($PSBoundParameters.address)      { $SshModuleHosts[$id].address    =  $PSBoundParameters.address   }
    If ($PSBoundParameters.port)         { $SshModuleHosts[$id].port       =  $PSBoundParameters.port      }
    If ($PSBoundParameters.BackColor)    { $SshModuleHosts[$id].BackColor  =  $PSBoundParameters.BackColor }
    If ($PSBoundParameters.ForeColor)    { $SshModuleHosts[$id].ForeColor  =  $PSBoundParameters.ForeColor }
    $SshModuleHosts[$id]

  } End {
    
    $SshModuleConfig                = SshModuleConfig
    $SshModuleConfig.hosts          = $SshModuleHosts
    SshModuleConfig        -SshConfig $SshModuleConfig
    
  }
  
}