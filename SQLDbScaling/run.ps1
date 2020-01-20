using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module AZ
Enable-AzureRmAlias
Import-Module AzureRM.Sql

# Write to the Azure Functions log stream.
Write-Output "PowerShell HTTP trigger function processed a request."

# Interact with the body of the request.
Write-Output $Request.Body
$sqlObj = $Request.Body
Wait-Debugger
if ($sqlObj) {
    # Get input parameters
    Write-Output "Read input params"
    $rgName = $sqlObj.RgName
    Write-Output "Resource group name $rgName"

    $dbName = $sqlObj.DbName
    Write-Output "Database name $dbName"

    $serverName = $sqlObj.ServerName
    Write-Output "Server Name $serverName"

    $edition = $sqlObj.Edition 
    $serviceObjName = $sqlObj.ScaleTo
    $subscriptionName = $sqlObj.SubsriptionName

    #Connect to Azure
    Write-Output "Connecting to subscription"
    #Connect-AzAccount -Subscription $subscriptionName

    #updating pricing tier Edition: standard, ServiceObjName: S1

    Set-AzureRmSqlDatabase -ResourceGroupName $rgName `
        -DatabaseName $dbName `
        -ServerName $serverName `
        -Edition $edition `
        -RequestedServiceObjectiveName $serviceObjName

    Write-Output "Updated SQL pricing"
    $status = [HttpStatusCode]::OK
    $body = "updated pricing tier to $edition"
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body = "pass correct input param."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $status
        Body       = $body
    })
