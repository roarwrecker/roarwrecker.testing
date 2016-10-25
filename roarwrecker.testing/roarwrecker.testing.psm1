
# dot source all scripts in module folderGet-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1' -File `    | Select-Object -ExpandProperty FullName `    | ForEach-Object { . $_ }
