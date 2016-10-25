<#
.Synopsis
   Tests if the specified path points to a module.
#>
function Test-ModulePath
{
    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory, 
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [System.IO.DirectoryInfo]
        $Path
    )

    Process
    {
        # Just check if module file exists, otherwise the path must be wrong
        Test-Path "$Path\$($Path.Name).psm1" -PathType Leaf
    }
}