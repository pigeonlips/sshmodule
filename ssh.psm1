Function GetScriptPath {
  [CmdletBinding()]
  Param
  (
    [Parameter(
      ParameterSetName='Leaf'
    )] [Switch]$Leaf,
    [Parameter(
      ParameterSetName='Parent'
    )] [Switch]$Parent,
    [Parameter(
      ParameterSetName='Name'
    )] [Switch]$Name
  )
  #returns the name of this script at run time.
  If ($Parent) { Split-Path $MyInvocation.PSCommandPath -Parent; Return }

  If ($Leaf) { Split-Path $MyInvocation.PSCommandPath -Leaf; Return }

  If ($Name) { Split-Path $MyInvocation.InvocationName; Return }

  $MyInvocation.PSCommandPath

}


Function SshAddressDynamicParam {

  [CmdletBinding()]
  Param ($DynamicParamDictionary)

  Write-Verbose "[$($MyInvocation.MyCommand.Name)] Begin ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
  $ParamAttr                                 = New-Object System.Management.Automation.ParameterAttribute
  $ParamAttr.ParameterSetName                = "load"
  $ParamAttr.Mandatory                       = $False
  $ParamAttr.Position                        = 1
  $ParamAttr.ValueFromPipeline               = $false
#     $ParamAttr.HelpMessage                     = "Help"

  $AttributeCollection    = New-Object 'Collections.ObjectModel.Collection[System.Attribute]'
  $AttributeCollection.Add($ParamAttr)
  $ValidateSetCollection   = @()
  $ValidateSetCollection  += "New"
  $ValidateSetCollection  += (SshModuleConfig).hosts.label
  

  #validate set
  $ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSetCollection
  $AttributeCollection.Add($ParamOptions)

  # alias
  $Alias      = ('label')
  $ParamAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList $Alias
  $AttributeCollection.Add($ParamAlias)

  #Create the dynamic parameter
  $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList @('load',[String[]], $AttributeCollection)

  # set the default to the first one in the validate set
  # TODO Need to get a default value into $PSBoundParameters["ApiHost"]
  # $PSBoundParameters["ApiHost"] = $ValidateSetCollection | select -first 1
  #$Parameter.Value = $ValidateSetCollection | select -first 1

  #$DynamicParamDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
  $DynamicParamDictionary.Add('load', $Parameter)
  $DynamicParamDictionary

}

Function SshModuleConfig {
  [CmdletBinding()]
  param ($SshConfig)

    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
    $SshConfigFile                     = "$(GetScriptPath -parent)\sshmodule.json"

    If ($SshConfig) {

      if ( -not $SshConfig.hosts ) {
        
        $SshConfig.hosts = @()
        
      }
      Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Writing to  ""$($SshConfigFile)"" : $($MyInvocation.MyCommand.Name)"
      $SshConfig    | ConvertTo-Json      | Out-File   -FilePath $SshConfigFile -Encoding ascii
      return

    }

    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Reading config $($PuppetConfigFile)"
    # TODO Without Powershell 5 , you need to join the json on new line for ConvertFrom-Json to work - lame !
    #$PuppetConfig                         = Get-Content $PuppetConfigFile -ErrorAction SilentlyContinue | ConvertFrom-Json
    $SshConfig    = ((Get-Content $SshConfigFile    -ErrorAction SilentlyContinue ) -join "`n" ) | ConvertFrom-Json
    Return $SshConfig

}

Function AddSshAddress {
  [CmdletBinding()]
  Param (
   [Parameter(ParameterSetName='__AllParameterSets', Mandatory=$True)]
   [String]$Address,
   [Parameter(ParameterSetName='__AllParameterSets', Mandatory=$False)]
   [String]$Port = 22,
   [Parameter(ParameterSetName='__AllParameterSets', Mandatory=$False)]
   [String]$Label,
   [Parameter(ParameterSetName='__AllParameterSets', Mandatory=$False)]
   [String]$BackColor = "black",
   [Parameter(ParameterSetName='__AllParameterSets', Mandatory=$False)]
   [String]$ForeColor = "white"
   
  )

  Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
  $SshConfig     = SshModuleConfig
  
  If ( -not $SshConfig ) {
    
    Write-Warning "No SshConfig file. Run Initialize-SshModule to create one!"
    Return
  
  }
  
  If (-Not $Label) {
    
    $Label       = Read-Host -Prompt "You can provide a label for ""$($Address)"". If omited I will use ""$($Address)"" as the label"
    
    If ( (-not $Label) -or ($Label -eq "") ) {
      
      Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Changing Label to $($Address)"
      $SshHost   | Add-Member -MemberType NoteProperty  -Name label              -Value $Address
      
    }

  }

  $SshHost       = New-Object -TypeName pscustomobject
  $SshHost       | Add-Member -MemberType NoteProperty  -Name address      -Value $Address
  $SshHost       | Add-Member -MemberType NoteProperty  -Name port         -Value $Port
  $SshHost       | Add-Member -MemberType NoteProperty  -Name label        -Value $Label
  $SshHost       | Add-Member -MemberType NoteProperty  -Name BackColor    -Value $BackColor
  $SshHost       | Add-Member -MemberType NoteProperty  -Name ForeColor    -Value $ForeColor
  
  Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Adding $($SshHost.address) as $($SshHost.label)"
  $SshConfig.hosts += $SshHost
  SshModuleConfig -SshConfig $SshConfig
  Return

}

Function Explain-SshModule {
  <#
  .SYNOPSIS
    show a brief help screen
  #>
  Param (
    [Parameter(Position = 0 )]
    [String]$color = "White"
  )

  # draw a line break
  Write-Host ("-" * $($Host.UI.RawUI.WindowSize.Width -1) ) -ForegroundColor Gray

  # there is a whole plane in here
  $Text = 's  s  h      m  o  d  u  l  e'

  # draw it !
  $Text | ForEach {

    # print each part, and centre it in the screen
    Write-Host (" " * ($($($Host.UI.RawUI.WindowSize.Width -1) / 2) - $_.Length /2)) $_ -ForegroundColor $color

  }

  # draw a line break
  Write-Host ("-" * $($Host.UI.RawUI.WindowSize.Width -1) )  -ForegroundColor Gray

  # show the commands available
  Write-Host "Command's now available : " -ForegroundColor $color
  Get-Command -Module ((GetScriptPath -Leaf) -replace '.psm1','') -Name *-* -CommandType function | Sort-Object Noun | Get-Help | Select Name, Synopsis | Out-Host
  Write-Host "use Get-Help " -NoNewLine
  Write-Host "CommandName " -NoNewLine -ForegroundColor $color
  Write-Host "for more details"
  Write-Host
  Write-Host "You can configure this module through the following file : " -NoNewLine
  Write-Host """$(GetScriptPath -parent)\sshmodule.json""" -ForegroundColor $color
  # draw a line break
  Write-Host ("-" * $($Host.UI.RawUI.WindowSize.Width -1) )  -ForegroundColor Gray

}


Function Initialize-SshModule {
<#
  .SYNOPSIS
    Set up this modules config file
#>
  [CmdletBinding()]
  Param (
   [Parameter(ParameterSetName='__AllParameterSets')] [Switch]$Force
  )

  Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"

  $SshConfig     = SshModuleConfig
  
  If (  ( -not $SshConfig ) -or ( $force )  ) {
    
    Write-Warning "No sshmodule Config file. Creating one for you"
    
    If ( Get-Command ssh.exe -ErrorAction SilentlyContinue ) {
        
        $ssh_location = "ssh.exe"
        Write-Host "I found ssh.exe in `$env:path ! You should get a prize !"
    
    } Else {
      
      $possible_ssh_locations  = @()
      $possible_ssh_locations += "C:\Program Files\Git\usr\bin\ssh.exe"
      $possible_ssh_locations  | ForEach-Object {
        
        If (  (Test-Path $_) -and (-not $ssh_location)  ) {
        
          $ssh_location = $_
        
        } # if found ssh and not set ssh location
        
      } # end for each possible ssh location

      if (-not $ssh_location) {
      
        Write-Warning "couldnt find a working ssh.exe for you !"
        Write-Host "This module is just a fancey wrapper for the ssh.exe. You'll need this for the module to work. You cancel this and ..."
        Write-Host "[>] If you have chocolatey installed try :"
        Write-Host "    choco install openssh"
        Write-Host ""
        Write-Host "[>] If you have ssh installed but dont know the location of it try:"
        Write-Host "    Get-ChildItem c:\ -Recurse -Filter ssh.exe -ErrorAction SilentlyContinue | select -ExpandProperty fullname"
        Write-Host ""
        Write-Host "Then you can re-run this by using the following command :"
        Write-Host "  Initialize-SshModule -Force"
        Write-Host ""
        Write-Host "Altenativly , if you have it installed and know the location of it you can provide it now"
        $ssh_location = $(read-host -Prompt "can i haz full path to ssh.exe?")
      
      } # if still not ssh_location
      
    } # end if ssh not on path
    
    If (Get-Command $ssh_location -ErrorAction SilentlyContinue) {
      
      Write-Host "I found ssh.exe in the following path : ""$ssh_location"" at version ""$((Get-Command $ssh_location).Version)"""
      Write-Host "You can change this by editing this modules config file"

      $SshHosts         = @()
      $SshConfig        = New-Object -TypeName pscustomobject
      $SshConfig        | Add-Member -MemberType NoteProperty  -Name ssh_location       -Value $ssh_location
      $SshConfig        | Add-Member -MemberType NoteProperty  -Name hosts              -Value $SshHosts
      SshModuleConfig -SshConfig $SshConfig
      
      Write-Host "If you want to place it somewhere where powershell can find it, put it in one of the following folders or add this folder to `$env:PSModulePath"
      [Environment]::GetEnvironmentVariable("PSModulePath", "Machine") -split ";" | Out-Host
      
    } Else {
      
      Write-Warning "Could not validate ssh.exe"
      
    }# end if ssh is a usable command

  } Else {
    
    Write-Host "You aleady have a sshmodule Config file. You can force this module to create a new one (all saved connections will be lost) with : "
    Write-Host "    Initialize-SshModule -Force"
    
  }

  Return

}
# -------------------------------------------------------------------------------------------------------------------------------------
#                C  O  D  E     T  H  A  T     I  S     R  U  N     O  N     I  M  P  O  R  T  -  M  O  D  U  L  E
# -------------------------------------------------------------------------------------------------------------------------------------

# I have split out all the user functions into seprate script files.
Get-ChildItem "$(GetScriptPath -Parent)\*.ps1" | Foreach-Object {

  $script = $_.BaseName
  Write-Verbose "$(GetScriptPath -Leaf) ~ Importing : $($_.FullName)"

  Try {

    # Need to load it by dot sourcing it.
    . $_.FullName

  } Catch {

    # opps - fail
    Write-Warning "[$($MyInvocation.MyCommand.Name)] Failed to Import $($Script)"
    Write-Error $_

  } # end Catch

} # end for each ps1 file

# export (make them available) only for functions that have a hyphen in the name, helper functions shouldn't have them
Export-ModuleMember -Function *-* -Alias *


# init the Module
Initialize-SshModule

# show the help
Explain-SshModule