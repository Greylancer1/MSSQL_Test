###  The below function is our wrapper function; it will call both other functions
###  We will give it all the parameters that the other two functions need: the server name, the script location, the name of the script, and the database name
Function Build-VersionName {
    Param (
        [string]$server
        , [string]$location
        , [string]$name
        , [string]$database
    )
    Process
    {
        $commandscript = Get-ScriptByVersion -server $server -location $location -name $name
        Execute-SQL -server $server -database $database -commandtext $commandscript
    }
}