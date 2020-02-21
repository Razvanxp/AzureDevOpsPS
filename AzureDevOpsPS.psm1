# Azure DevOps PS module

function Add-AzureDevOpsAccount {
    
    param(
        $azureDevOpsPatToken
    )

    $encodedAzureDevOpsPatToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$azureDevOpsPatToken"))
    $Headers = @{Authorization = ("Basic {0}" -f $encodedAzureDevOpsPatToken) }

    return $Headers

}

function Get-AzDevOpsServiceEndpoint {
    <#
    .Synopsis
       For now the function gets a Azure DevOps service endpoint ID.
    .DESCRIPTION
       Later it will be expanded to do more stuff - see TODO
    .EXAMPLE
       Get-AzDevOpsServiceEndpointId -organization "devopsglobal" -project "Azure-Samples" -Headers $headers -endpointName "Visual Studio Enterprise (43425303-a7cb-41ce-a1ac-6c84223444235)"
    .OUTPUTS
       e.g. 125b62eb-4fd8-4cbc-a671-88f2eb23dcac
    #>

    # TODO - add switch and expand function to get more properties such as Name, ID etc.
    param(
        $organization,
        $project,
        $endpointName,
        $Headers
    )
 
    $requestParameters = @{
        
        Uri     = "https://dev.azure.com/$organization/$project/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2"
        Method  = "GET"
        Headers = $Headers

    }

    (((Invoke-RestMethod @requestParameters -UseBasicParsing).value) | Where-Object { $_.name -eq $endpointName })
}

function New-AzDevOpsServiceEndpoint {
    
<#  New-AzDevOpsServiceEndpoint -Organization "devopsglobal" `
                        -Project "Azure-Samples" `
                        -tenantid "56f9bee4-d4f1-4551-9e9b-8d9a7bf1d004" `
                        -servicePrincipalId "56232a06-9e8e-4af9-822a-0e9b80d8f4f3" `
                        -appPassword "3242342" `
                        -subscriptionName "Visual Studio Enterprise" `
                        -subscriptionId "b5e05303-a7cb-41ce-a1ac-6c8420a44235" `
                        -AzureDevOpsServiceName "Test2" `
                        -headers $headers #>

        param(
            $tenantid,
            $servicePrincipalId,
            $Organization,
            $Project,
            $appPassword,
            $subscriptionName,
            $subscriptionId,
            $AzureDevOpsServiceName,
            $headers
        )
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
            Headers = $headers
            Body = $requestBody
        
        }
        
        $response = Invoke-RestMethod @requestParameters -UseBasicParsing

    }

function Get-AzureDevOpsGroupId {
    
    # Get-AzureDevOpsGroupId -azDevOpsGroup "[Buzzer]\Buzzer Team" -organization "devopsglobal" -Headers $headers
    # TODO - add switch and expand function to get properties as well e.g ID.

    param(
        $azDevOpsGroup,
        $Headers,
        $organization
    )

    $requestParameters = @{
        
        Uri     = "https://vssps.dev.azure.com/$organization/_apis/graph/groups?api-version=5.0-preview.1"
        Method  = "GET"
        Headers = $Headers        

    }

    ((Invoke-RestMethod @requestParameters -UseBasicParsing).value | Where-Object { $_.principalName -eq $azDevOpsGroup }).originid

}

function Get-AzureDevOpsProjectId {

    # Get-AzureDevOpsProjectId -organization "devopsglobal" -project "Azure-Samples" -Headers $headers
    
    param(
        $organization,
        $project,
        $Headers
    ) 
    
    $requestParameters = @{
        
        Uri     = "https://dev.azure.com/$organization/_apis/projects?api-version=5.0"
        Method  = "GET"
        Headers = $Headers

    }
    
    ((Invoke-RestMethod @requestParameters -UseBasicParsing).value | Where-Object { $_.Name -eq $project }).id

}

function Get-AzureDevOpsVarGroup {
    
    # Get-AzureDevOpsVarGroup -organization "devopsglobal" -project "Azure-Samples" -varGroup "var2" -headers $headers

    param(
        $organization,
        $project,
        $varGroup,
        $headers
    )

    $requestProperties = @{
    
        Method  = "Get"
        Uri     = "https://dev.azure.com/$organization/$project/_apis/distributedtask/variablegroups?groupName=$varGroup&queryOrder=IdDescending&api-version=5.0-preview.1"
        Headers = $headers
    }

    Invoke-RestMethod @requestProperties
}

function Get-AzureDevOpsVarGroupSecurity {
    
    # Get-VariableGroupSecurity -Headers $headers -organization devopsglobal -varGroupId 2 -groupId 8213a116-e7d5-47ae-a24a-b8324d8cd45f -projectid 3214bf44-6448-4c39-95c7-0159d4ff2b7e

    param (
        $organization,
        $varGroupId,
        $groupId,
        $projectid,
        $Headers
    )
    
    $encodedValue = [System.Web.HttpUtility]::UrlEncode('$' + $varGroupId) 
    $Uri = "https://dev.azure.com/$organization/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$projectId$encodedValue"
    
    $requestParameters = @{
        Uri     = $Uri
        Method  = "GET"
        Headers = $headers
    }

    Write-output $requestParameters.uri

    $requestParameters

    (Invoke-RestMethod @requestParameters).value
}

function Add-AzureDevOpsVarGroupRole {

    # Add-VariableGroupRole -Headers $headers -organization devopsglobal -varGroupId 2 -projectid c1c4bf44-6448-4c39-95c7-0159d4ff2b7e -groupId "86b8a116-e7d5-47ae-a24a-b8324d8cd45f" -role "Administrator"

    param (
        $organization,
        $projectid,
        $varGroupId,
        $groupId,
        [ValidateSet("Reader", "User", "Administrator")]
        $role,
        $Headers
    )
    
    $encodedValue = [System.Web.HttpUtility]::UrlEncode('$' + $varGroupId) 
    $Uri = "https://dev.azure.com/$organization/_apis/securityroles/scopes/distributedtask.variablegroup/roleassignments/resources/$projectId$encodedValue" + "?api-version=5.0-preview.1"
    
    $requestBody = "[{roleName: `"$role`", userId: `"$groupId`" }]"

    $requestParameters = @{
        Uri         = $Uri
        Method      = "PUT"
        Headers     = $headers
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
        $Organization,
        $AccessToken
    )

    Write-Host "Logging in to $Organization" 
    echo $AccessToken | az devops login --organization "https://dev.azure.com/$Organization/"

}

function New-AzDevOpsWiqlQueryResult {

    param(
        $organization,
        $query,
        $Headers
    )

    $Headers.Remove('Content-Type') 
    $Headers.Add("Content-Type", "application/json")
    
    $body = @{
  
       "query" = $query
    
    } | ConvertTo-Json

    $requestParameters = @{
        
        Uri     = "https://dev.azure.com/$organization/_apis/wit/wiql?api-version=5.1"
        Method  = "POST"
        Headers = $Headers
        Body = $body

    }

    (Invoke-RestMethod @requestParameters -UseBasicParsing)
}

function Get-AzDevOpsWorkItem {
    
    param(
        $Organization,
        $id,
        $Headers
    )
    
    $requestParameters = @{
    
        Uri = "https://dev.azure.com/$Organization/_apis/wit/workitems/$id`?`$expand=all&api-version=5.1"
        Method = 'GET'
        Headers = $Headers
    
    }
    
    (Invoke-RestMethod @requestParameters -UseBasicParsing)

}

function New-AzDevOpsWorkItem {
    
    param(
        $Organization,
        $Project,
        $WorkItemType,
        $WorkItemName,
        $Headers
    )

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
        $Organization,
        $workitemId,
        $workitemRev,
        $releaseWorkItemId,
        $Headers
    )

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
    $Organization,
    $Project,
    $deploymentGroupName,
    $Headers    
    )

    $check = @{
    
    Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/deploymentgroups?api-version=5.0-preview.1"
    Method = 'GET'
    Headers = $Headers
  
  }

    $body = @{
                name = "$deploymentGroupName"
                description = "Deployment group created during automatic deployment"
            } | ConvertTo-Json

    (Invoke-RestMethod @check -UseBasicParsing).value | where {$_.Name -eq $deploymentGroupName}

}

function New-AzDevOpsDeploymentGroup {

    # New-AzDevOpsDeploymentGroup -Organization 'devopsglobal' -Project 'Azure-Samples' -deploymentGroupName "Test3" -Headers $headers
    
    param(
        $Organization,
        $Project,        
        $deploymentGroupName,
        $headers
    )

    $body = @{
            name = "$deploymentGroupName"
            description = "Deployment group created during automatic deployment"
        } | ConvertTo-Json

    $create = @{
        Uri = "https://dev.azure.com/$Organization/$Project/_apis/distributedtask/deploymentgroups?api-version=5.0-preview.1"
        Method = 'POST'
        Headers = $Headers
        Body = $body
        ContentType = "application/json"
    }

    (Invoke-RestMethod @create -UseBasicParsing)

}

