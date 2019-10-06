Function Select-Ssh {
<#
  .SYNOPSIS
    show a list of saved ssh connections
    
  .DESCRIPTION
    show a list of saved ssh connections
    
  .PARAMETER id
    filter by id number
    
  .PARAMETER label
    filter by label
    
  .PARAMETER address
    filter by address
    
  .PARAMETER port
    filter by port
        
  .EXAMPLE
    PS> select-ssh -port 100
    # show all saved ssh connections with port 100

  .INPUTS
    None
    
  .OUTPUTS
    [pscustomobject]
    object showing the stored ssh connections in this modules config. This can be piped to other commands
    
  .NOTES
    Author: pigeonlips
#>
  [CmdletBinding(
    PositionalBinding                  = $True
  )]

  Param (
        
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, Position=0, ValueFromPipeline = $False)]
    [String]$label = ".*",

    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, Position=1, ValueFromPipeline = $False)]
    [String]$address = ".*",

    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, Position=2, ValueFromPipeline = $False)]
    [String]$port = ".*" ,
    
    [Parameter(ParameterSetName = "__AllParameterSets", Mandatory=$False, Position=3, ValueFromPipeline = $False)]
    [String]$id = ".*"
  )

  Begin {
    
    Write-Verbose "[$($MyInvocation.MyCommand.Name)] ~ Started ""$(GetScriptPath -Parent)\$(GetScriptPath -Leaf)"" : $($MyInvocation.MyCommand.Name)"
    $SshModuleConfig    = (SshModuleConfig).hosts | Sort Label
    $DisplaySet         = 'id','label','address', 'port'
    $DisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$DisplaySet)
    $PSStandardMembers  = [System.Management.Automation.PSMemberInfo[]]@($DisplayPropertySet)
    $SshModuleConfig    | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    
  } Process {
    
    $i = 0
    $SshModuleConfig | % {
    
      $_ | Add-Member -MemberType NoteProperty  -Name id            -Value $i
      $i ++
    
    }

    $SshModuleConfig | ? { ($_.id -match $id) -and ($_.port -match $port) -and ($_.address -match $address) -and ($_.label -match $label) } #| select id , label , address , port

  } End {
    

  }
  
}