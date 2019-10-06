Function Enter-Ssh {
<#
  .SYNOPSIS
    ssh to a host
    
  .DESCRIPTION
    Use ssh.exe to ssh to a host. You can save connections and use -load to ssh into it again later.
    
  .PARAMETER Address
    address to ssh into. In the format of User@host
    
  .PARAMETER Port
    Port to use. Default is 22
    
  .PARAMETER Load
    label of saved connection to ssh into.
    
  .EXAMPLE
    PS>
    #

  .INPUTS
    
  .OUTPUTS
   
  .NOTES
    Author: pigeonlips
#>
  [CmdletBinding(
    PositionalBinding                  = $False,
    ConfirmImpact                      = 'high',
    SupportsShouldProcess
  )]

  Param (
    [Parameter(ParameterSetName = "direct", Mandatory=$True, Position=0, ValueFromPipelineByPropertyName = $True)]
    [Alias('host' , 'hostname' , 'computer')]
    [String]$Address ='.*',
    
    [Parameter(ParameterSetName = "direct", Mandatory=$False, Position=1, ValueFromPipelineByPropertyName = $True)]
    [String]$Port = '22',
    
    [Parameter(ParameterSetName = "direct", Mandatory=$False, ValueFromPipelineByPropertyName = $True)]
    [String]$BackColor = "black",

    [Parameter(ParameterSetName = "direct", Mandatory=$False, ValueFromPipelineByPropertyName = $True)]
    [String]$ForeColor = "white"
  )

  DynamicParam {
    $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    return SshAddressDynamicParam $Dictionary
  }
  
  Begin {
    
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Begin ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
    If ( $($PSBoundParameters["Address"]) -eq 'New' ) {
        $PSBoundParameters["Load"] = Read-Host "address (user@hostnameorip) :"
    }

    $HostForegroundColor = $Host.ui.RawUI.ForegroundColor
    $HostBackgroundColor = $Host.ui.RawUI.BackgroundColor
    $HostWindowTitle     = $Host.ui.RawUI.WindowTitle
    
  } Process {
    
    If ($PSCmdlet.ParameterSetName -eq 'load') {
      
      $Loaded  = ((SshModuleConfig).hosts | Where-Object { $_.label -eq $PSBoundParameters["load"] })
      $Address = $Loaded.address
      $Port    = $Loaded.Port
      Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Process : Loaded $address"
    
    }
    
    $ArgumentList     = @()
    $ArgumentList    += "$address"
    $ArgumentList    += "-p $port"

    If ($BackColor) { $Host.UI.RawUI.BackgroundColor = $BackColor }
    If ($ForeColor) { $Host.UI.RawUI.ForegroundColor = $ForeColor }
                      $Host.UI.RawUI.WindowTitle     = "ssh://$($address):$($port)"
    Clear-Host
    
    Try {
      
      Write-Verbose "[$($MyInvocation.MyCommand.Name)] Process ~ & ""$((SshModuleConfig).ssh_location)"" $ArgumentList"
      & "$((SshModuleConfig).ssh_location)" $ArgumentList
      
    } Finally {
      
      $Host.ui.RawUI.ForegroundColor = $HostForegroundColor
      $Host.ui.RawUI.BackgroundColor = $HostBackgroundColor
      $Host.ui.RawUI.WindowTitle     = $HostWindowTitle
      Clear-Host
    
    } # end try catch
    
  } End {
    
    If ($address -notin $((SshModuleConfig).hosts | select -ExpandProperty address) ) {
      
      Write-Host "You can save this address for future. Want to do this ?"

      If (  $PSCmdlet.ShouldProcess( "$address" , "Save" )  ) {
        AddSshAddress              -Address $address     `
                                   -Port $port           `
                                   -BackColor $BackColor `
                                   -ForeColor $ForeColor
      } # end if should process

    } # end if this is a new apihost

  } # end end
  
} # end function

Set-Alias ssh   Enter-Ssh