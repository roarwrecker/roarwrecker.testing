<#
.Synopsis
   Creates a new test base for a PS module.
.DESCRIPTION
   
.EXAMPLE
   
.EXAMPLE
   
#>
function Update-ModuleTests
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        # Path to the module folder
        [Parameter(
        ValueFromPipeline)]
        [ValidateScript({ Test-Path $_ })]
        [string]
        $Path
    )

    Begin
    {
    }
    Process
    {
        if (!(Test-ModulePath -Path $Path))
        {
            throw "The path '$Path' is not a valid module, because it does not contain a corresponding *.psm1 file"
        }
    }
    End
    {
    }
}