# Azure DevOps PS module
function Test-AzDevOpsSession {
    if ($null -eq $Global:headers) {
        Write-Warning "You are not connected to Azure DevOps use Add-AzDevOpsAccount -accesstoken '<PAT>' to connect."
        break
    }
}
function Add-AzDevOpsAccount {
    
    # Add-AzDevOpsAccount -accesstoken "000000000000000000000"
    
    param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $accesstoken
    )

    $encodedAzureDevOpsPatToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$accesstoken"))
    $Global:Headers = @{Authorization = ("Basic {0}" -f $encodedAzureDevOpsPatToken) }

    return $Headers
}

function Get-AzDevOpsServiceEndpoint {
    <#
    .Synopsis
       For now the function gets a Azure DevOps service endpoint ID.
    .DESCRIPTION
       Later it will be expanded to do more stuff - see TODO
    .EXAMPLE
       Get-AzDevOpsServiceEndpointId -organization "devopsglobal" -project "Azure-Samples" -Headers $headers -endpointName "<endpoint>"
    .OUTPUTS
       e.g. 1232362eb-4fd8-4cbc-a671-88f2eb23dcaz
    #>

    # TODO - add switch and expand function to get more properties such as Name, ID etc.
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $true)]
        $project,
        [Parameter(Mandatory = $true)]
        $endpointName,
        [Parameter(Mandatory = $false)]
        $headers
    )

    Test-AzDevOpsSession

    $requestParameters = @{
        
        Uri     = "https://dev.azure.com/$organization/$project/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2"
        Method  = "GET"
        Headers = $global:Headers

    }

    (((Invoke-RestMethod @requestParameters -UseBasicParsing).value) | Where-Object { $_.name -eq $endpointName })
}
function New-AzDevOpsServiceEndpoint {
    
<#  New-AzDevOpsServiceEndpoint -Organization "<organization>" `
                        -Project "<project>" `
                        -tenantid "<tenantId>" `
                        -servicePrincipalId "<service principal Id>" `
                        -appPassword "<password>" `
                        -subscriptionName "<subscription name>" `
                        -subscriptionId "<subscription id>" `
                        -AzureDevOpsServiceName "<new name>" `
                        -headers $headers #>

            param(
            [CmdletBinding]
            [Parameter(Mandatory = $true)]
            $tenantid,
            [Parameter(Mandatory = $true)]
            $servicePrincipalId,
            [Parameter(Mandatory = $true)]
            $Organization,
            [Parameter(Mandatory = $true)]
            $Project,
            [Parameter(Mandatory = $true)]
            $appPassword, # TODO - Secure this
            [Parameter(Mandatory = $true)]
            $subscriptionName,
            [Parameter(Mandatory = $true)]
            $subscriptionId,
            [Parameter(Mandatory = $true)]
            $AzureDevOpsServiceName,
            [Parameter(Mandatory = $false)]
            $headers
        )

        Test-AzDevOpsSession

             $requestBody = @{
              "authorization"= @{
                "parameters"= @{
                  "tenantid"= "$tenantId"
                  "serviceprincipalid"= "$servicePrincipalId"
                  "authenticationType"= "spnKey"
                  "serviceprincipalkey"= "$appPassword"
                }
            "scheme"= "ServicePrincipal"
          }
              "data"= @{
                "subscriptionId"= "$subscriptionId"
                "subscriptionName"= "$subscriptionName"
                "environment"= "AzureCloud"
                "scopeLevel"= "Subscription"
                "creationMode"= "Manual"
              }
              "name"= "$AzureDevOpsServiceName"
              "type"= "azurerm"
              "url"= "https=//management.azure.com/"
        
        } | ConvertTo-Json


        $requestParameters = @{
        
            Uri = "https://dev.azure.com/$Organization/$Project/_apis/serviceendpoint/endpoints?api-version=5.1-preview.2"
            Method = 'POST' 
            ContentType = "application/json"
            Headers = $global:headers
            Body = $requestBody
        
        }
        
        Invoke-RestMethod @requestParameters -UseBasicParsing
}2
function Add-AzDevOpsEndpointRole {

        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $groupId,
        [Parameter(Mandatory = $true)]
        $endpintId,
        [Parameter(Mandatory = $true)]
        $projectId,
        [Parameter(Mandatory = $true)]
        $organizationName,
        [Parameter(Mandatory = $false)]
        $headers
    )
        Test-AzDevOpsSession

        $requestBody = "[{roleName: `"User`", userId: `"$groupId`"}]"

        $requestParameters = @{

            Uri = "https://$organizationName.visualstudio.com/_apis/securityroles/scopes/distributedtask.serviceendpointrole/roleassignments/resources/$projectId`_$endpintId`?api-version=5.0-preview.1"
            Method = "PUT"
            Headers = $global:headers
            Body = $requestBody
            ContentType = "application/json";
        
        }

        Invoke-RestMethod @requestParameters -UseBasicParsing
}

function Get-AzDevOpsSecurityGroup {
    
    # Get-AzDevOpsSecurityGroup -securitygroup "[Buzzer]\Buzzer Team" -organization "devopsglobal" -Headers $headers
    # TODO - add switch and expand function to get properties as well e.g ID.
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $securitygroup,
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $false)]
        $Headers
    )

    Test-AzDevOpsSession

    $requestParameters = @{
        
        Uri     = "https://vssps.dev.azure.com/$organization/_apis/graph/groups?api-version=5.0-preview.1"
        Method  = "GET"
        Headers = $Global:headers        

    }

    ((Invoke-RestMethod @requestParameters -UseBasicParsing).value | Where-Object { $_.principalName -eq $securitygroup })

}

function Get-AzDevOpsProject {

    # Get-AzDevOpsProject -organization "devopsglobal" -project "Azure" -Headers $headers
    
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $true)]
        $project,
        [Parameter(Mandatory = $false)]
        $Headers
    ) 
    
    Test-AzDevOpsSession

    $requestParameters = @{
        
        Uri     = "https://dev.azure.com/$organization/_apis/projects?api-version=5.0"
        Method  = "GET"
        Headers = $global:headers

    }
    
    ((Invoke-RestMethod @requestParameters -UseBasicParsing).value | Where-Object { $_.Name -eq $project })

}

function Get-AzDevOpsVarGroup {
    
    # Get-AzDevOpsVarGroup -organization "devopsglobal" -project "Azure-Samples" -varGroup "var2" -headers $headers

        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $true)]
        $project,
        [Parameter(Mandatory = $true)]
        $varGroup,
        [Parameter(Mandatory = $false)]
        $headers
    )

    Test-AzDevOpsSession

    $requestProperties = @{
    
        Method  = "Get"
        Uri     = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups?groupName=$varGroup&queryOrder=IdDescending&api-version=5.0-preview.1"
        Headers = $Global:headers
    }

    Invoke-RestMethod @requestProperties
}

function Get-AzDevOpsVarGroupSecurity {
    
    # Get-VariableGroupSecurity -Headers $headers -organization devopsglobal -varGroupId 2 -groupId 8213a116-e7d5-47ae-a24a-b8324d8cd45f -projectid 3214bf44-6448-4c39-95c7-0159d4ff2b7e

    param (
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $true)]
        $varGroupId,
        [Parameter(Mandatory = $true)]
        $groupId,
        [Parameter(Mandatory = $true)]
        $projectid,
        [Parameter(Mandatory = $false)]
        $Headers
    )
    
    Test-AzDevOpsSession

    $encodedValue = [System.Web.HttpUtility]::UrlEncode('$' + $varGroupId) 
    $Uri = "https://dev.azure.com/$organization/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$projectId$encodedValue"
    
    $requestParameters = @{
        Uri     = $Uri
        Method  = "GET"
        Headers = $Global:headers
    }

    Write-output $requestParameters.uri

    $requestParameters

    (Invoke-RestMethod @requestParameters).value
}

function Add-AzDevOpsVarGroupRole {

    # Add-VariableGroupRole -Headers $headers -organization devopsglobal -varGroupId 2 -projectid c1c4bf44-6448-4c39-95c7-0159d4ff2b7e -groupId "86b8a116-e7d5-47ae-a24a-b8324d8cd45f" -role "Administrator"

    param (
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $true)]
        $projectid,
        [Parameter(Mandatory = $true)]
        $varGroupId,
        [Parameter(Mandatory = $true)]
        $groupId,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Reader", "User", "Administrator")]
        $role,
        [Parameter(Mandatory = $false)]
        $Headers
    )

    Test-AzDevOpsSession

    $encodedValue = [System.Web.HttpUtility]::UrlEncode('$' + $varGroupId) 
    $Uri = "https://dev.azure.com/$organization/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$projectId$encodedValue" + "?api-version=5.0-preview.1"
    
    $requestBody = "[{roleName: `"$role`", userId: `"$groupId`" }]"

    $requestParameters = @{
        Uri         = $Uri
        Method      = "PUT"
        Headers     = $Global:headers
        Body        = $requestBody
        ContentType = "application/json; api-version=5.0-preview.1"
    }

    Write-output $requestParameters.uri

    $requestParameters

    (Invoke-RestMethod @requestParameters)
}

# Boards

function Add-AzDevOpsCliLogin {

        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $AccessToken
    )

    Write-Host "Logging in to $Organization" 
    Write-Output $AccessToken | az devops login --organization "https://dev.azure.com/$Organization/"

}

function Find-AzDevOpsWorkItem {

        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $organization,
        [Parameter(Mandatory = $true)]
        $query,
        [Parameter(Mandatory = $false)]
        $Headers
    )

    Test-AzDevOpsSession

    $Headers = $Global:headers

    $Headers.Remove('Content-Type') 
    $Headers.Add("Content-Type", "application/json")
    
    $body = @{
  
       "query" = $query
    
    } | ConvertTo-Json

    $requestParameters = @{
        
        Uri     = "https://dev.azure.com/$organization/_apis/wit/wiql?api-version=5.1"
        Method  = "POST"
        Headers = $headers
        Body = $body

    }

    (Invoke-RestMethod @requestParameters -UseBasicParsing)
}

function Get-AzDevOpsWorkItem {
    
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $id,
        [Parameter(Mandatory = $false)]
        $Headers
    )
    
    Test-AzDevOpsSession

    $requestParameters = @{
    
        Uri = "https://dev.azure.com/$Organization/_apis/wit/workitems/$id`?`$expand=all&api-version=5.1"
        Method = 'GET'
        Headers = $Global:headers
    
    }
    
    (Invoke-RestMethod @requestParameters -UseBasicParsing)

}

function New-AzDevOpsWorkItem {
    
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $Project,
        [Parameter(Mandatory = $true)]
        $WorkItemType,
        [Parameter(Mandatory = $true)]
        $WorkItemName,
        [Parameter(Mandatory = $false)]
        $Headers
    )

    Test-AzDevOpsSession

    $Headers = $Global:headers

    $Headers.Remove('Content-Type') 
    $Headers.Add('Content-Type', 'application/json-patch+json')

    $Body = @()

    class RequestBody {
        [string]$op = "add"
        [string]$path = "/fields/System.Title"
        [string]$from = $null
        [string]$value = $WorkItemName
        }

    $row = [RequestBody]::New() 
    $Body += $row
    $BodyJson = ConvertTo-Json -InputObject $Body
    $BodyJson

    
    $requestParameters = @{
    
        Uri = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/`$$WorkItemType`?api-version=5.1"
        Method = 'POST'
        Headers = $Headers
        Body = $BodyJson
    
    }
    
    (Invoke-RestMethod @requestParameters -UseBasicParsing)

}

function Update-AzDevOpsWorkItem {
    
  # Update-AzDevOpsWorkItem -Organization 'devopsglobal' -Project 'Azure-Samples' -releaseWorkItemId 1 -workitemId 6 -Headers $header
   
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $workitemId,
        [Parameter(Mandatory = $true)]
        $workitemRev,
        [Parameter(Mandatory = $true)]
        $releaseWorkItemId,
        [Parameter(Mandatory = $false)]
        $Headers
    )

    Test-AzDevOpsSession

    $Headers = $Global:headers

    $Headers.Remove('Content-Type') 
    $Headers.Add('Content-Type', 'application/json-patch+json')

$Body = @(
    @{
         'op' = "Test"
         'path' = '/rev'
         'from' = $null
         'value' = $workitemRev
     }
    @{ 
        "op"= "add"
        "path"= "/relations/-"
        "value"= @{
             "rel"= "System.LinkTypes.Related"
             "url"= "https://dev.azure.com/$Organization/_apis/wit/workItems/$workitemId"
             }
    }
) | ConvertTo-Json

    $requestParameters = @{
    
        Uri = "https://dev.azure.com/$Organization/_apis/wit/workitems/$releaseWorkItemId`?api-version=5.1"
        Method = 'PATCH'
        Headers = $Headers
        Body = $Body
    
    }
    
    (Invoke-RestMethod @requestParameters -UseBasicParsing)

}

function Get-AzDevOpsDeploymentGroup {
    
    # Get-AzDevOpsDeploymentGroup -Organization 'devopsglobal' -Project 'Azure-Samples' -deploymentGroupName "Test2" -Headers $headers

        param(
        [CmdletBinding]
    [Parameter(Mandatory = $true)]
    $Organization,
    [Parameter(Mandatory = $true)]
    $Project,
    [Parameter(Mandatory = $true)]
    $deploymentGroupName,
    [Parameter(Mandatory = $false)]
    $Headers    
    )

    Test-AzDevOpsSession

    $check = @{
    
    Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/deploymentgroups?api-version=5.0-preview.1"
    Method = 'GET'
    Headers = $global:headers
  
  }

    (Invoke-RestMethod @check -UseBasicParsing).value | Where-Object {$_.Name -eq $deploymentGroupName}
}

function New-AzDevOpsDeploymentGroup {

    # New-AzDevOpsDeploymentGroup -Organization 'devopsglobal' -Project 'Azure-Samples' -deploymentGroupName "Test3" -Headers $headers
    
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $Project,
        [Parameter(Mandatory = $true)]
        $deploymentGroupName,
        [Parameter(Mandatory = $false)]
        $headers
    )

    Test-AzDevOpsSession

    $body = @{
            name = "$deploymentGroupName"
            description = "Deployment group created during automatic deployment"
        } | ConvertTo-Json

    $create = @{
        Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/deploymentgroups?api-version=5.0-preview.1"
        Method = 'POST'
        Headers = $Global:headers
        Body = $body
        ContentType = "application/json"
    }

    (Invoke-RestMethod @create -UseBasicParsing)

}

function Add-AzDevOpsDeploymentGroupRole {

        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $groupId,
        [Parameter(Mandatory = $true)]
        $deploymentGroupId,
        [Parameter(Mandatory = $true)]
        $projectId,
        [Parameter(Mandatory = $true)]
        $organizationName,
        [Parameter(Mandatory = $false)]
        $Headers
    )

    Test-AzDevOpsSession

        $requestBody = "[{roleName: `"User`", userId: `"$groupId`"}]"

        $requestParameters = @{

            Uri = "https://$organizationName.visualstudio.com/_apis/securityroles/scopes/distributedtask.machinegrouprole/roleassignments/resources/$projectId`_$deploymentGroupId`?api-version=5.1-preview.1"
            Method = "PUT"
            Headers = $Global:headers
            Body = $requestBody
            ContentType = "application/json"

    }
    Invoke-RestMethod @requestParameters -UseBasicParsing
}

# Variable group operations

function Get-AzDevOpsVariableGroup {

    # Get-AzDevOpsVariableGroup -Organization 'devopsglobal' -Project 'Azure-Samples' -AzureDevOpsVarGroupName "test2" -headers $headers
    
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $Project,
        [Parameter(Mandatory = $true)]
        $AzureDevOpsVarGroupName,
        [Parameter(Mandatory = $false)]
        $headers
    )

    Test-AzDevOpsSession

    $requestParameters = @{
    
        Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups?api-version=4.1-preview.1"
        Method = 'GET'
        Headers = $Global:headers
        
    }

	(Invoke-RestMethod @requestParameters -UseBasicParsing).value | Where-Object {$_.name -eq $AzureDevOpsVarGroupName}
}

function New-AzDevOpsVariableGroup {

    # TODO - Document how the variable object works
    # New-AzDevOpsVariableGroup -Organization 'devopsglobal' -Project 'Azure-Samples' -AzureDevOpsVarGroupName 'Test' -azureDevOpsEndpointId '125b66eb-4fd8-4cbc-a671-88f2eb23dcac' -variables $variables -headers $headers

        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $Project,
        [Parameter(Mandatory = $true)]
        $AzureDevOpsVarGroupName,
        [Parameter(Mandatory = $true)]
        $azureDevOpsEndpointId,
        [Parameter(Mandatory = $true)]
        $variables,
        [Parameter(Mandatory = $false)]
        $headers
    )

    Test-AzDevOpsSession

    $requestBody = @{
          "type" = "AzureKeyVault"
          "name" = "$AzureDevOpsVarGroupName"
          "providerData" = @{
            "serviceEndpointId"= "$azureDevOpsEndpointId"
            "vault" = "$keyVaultName"
          }
          "variables" = "$variables"
} | ConvertTo-Json

    $requestParameters = @{
        
        Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups?api-version=4.1-preview.1"
        Method = "POST"
        Headers = $Global:headers
        Body = $requestBody
        ContentType = "application/json"

    }

    (Invoke-RestMethod @requestParameters -UseBasicParsing)

}

function Update-AzDevOpsVariableGroup {
    # TODO - Document how the variables object works
        param(
        [CmdletBinding]
        [Parameter(Mandatory = $true)]
        $Organization,
        [Parameter(Mandatory = $true)]
        $Project,
        [Parameter(Mandatory = $true)]
        $variableGroupId,
        [Parameter(Mandatory = $true)]
        $AzureDevOpsVarGroupName,
        [Parameter(Mandatory = $true)]
        $azureDevOpsEndpointId,
        [Parameter(Mandatory = $true)]
        $keyVaultName,
        [Parameter(Mandatory = $true)]
        $variables,
        [Parameter(Mandatory = $false)]
        $headers
    )
        Test-AzDevOpsSession

        $requestBody = @{
          "type" = "AzureKeyVault"
          "name" = "$AzureDevOpsVarGroupName"
          "providerData" = @{
            "serviceEndpointId"= "$azureDevOpsEndpointId"
            "vault" = "$keyVaultName"
          }
          "variables" = "$variables"
} | ConvertTo-Json

    $requestParameters = @{
        
        Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/variablegroups/$variableGroupId`?api-version=4.1-preview.1"
        Method = "PUT"
        Headers = $Global:headers
        Body = $requestBody
        ContentType = "application/json"

    }

    (Invoke-RestMethod @requestParameters -UseBasicParsing)

}
