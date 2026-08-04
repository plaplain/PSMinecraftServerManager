function New-ImportCmdletClassRawCode {
    param(
        [Parameter(Mandatory = $false)][array]$ClassesToMock
    )

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Exception for a Pester function')]

    $RawClassCode = ''

    foreach($Class in $ClassesToMock){
        $ClassName = $Class.ClassName
        $RawClassCode += "Class $ClassName {"

        # Constructors
        foreach($Constructor in $Class.Constructors){
            if($null -ne $Constructor){
                $SplitParameters = $Constructor.Split(';')
                $ConstructorParams = New-ImportCmdletParameterString -SplitParameters $SplitParameters
            }
            else {
                $ConstructorParams = ''
            }

            $RawClassCode += "$ClassName($ConstructorParams){}" + [System.Environment]::NewLine
        }

        # Methods
        foreach($Method in $Class.Methods){
            $MethodOutputType = $Method.OutputType
            $RawMethodCode = "[$MethodOutputType]$($Method.Name)("
            $SplitParameters = $Method.Inputs.Split(';')

            $RawMethodCode += New-ImportCmdletParameterString -SplitParameters $SplitParameters

            if($Method.OutputType -eq 'void'){
                $RawMethodCode += "){}" + [System.Environment]::NewLine
            }
            else{
                $RawMethodCode += "){return [$MethodOutputType]$($Method.Output)}" + [System.Environment]::NewLine
            }

            $RawClassCode += $RawMethodCode
        }

        $RawClassCode += "}"  + [System.Environment]::NewLine
    }

    $RawClassCode
}