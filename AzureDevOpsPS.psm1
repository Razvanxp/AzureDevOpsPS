# Azure DevOps PS module

function Add-AzureDevOpsAccount {
    
    param(
        $azureDevOpsPatToken
    )

    $encodedAzureDevOpsPatToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$azureDevOpsPatToken"))
    $Headers = @{Authorization = ("Basic {0}" -f $encodedAzureDevOpsPatToken) }

    return $Headers

}

function Get-AzDevOpsServiceEndpointId {
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

    (((Invoke-RestMethod @requestParameters -UseBasicParsing).value) | Where-Object { $_.name -eq $endpointName }).id
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
