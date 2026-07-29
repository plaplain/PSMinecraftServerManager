---
document type: cmdlet
external help file: MinecraftServerManager-Help.xml
HelpUri: ''
Locale: en-US
Module Name: MinecraftServerManager
ms.date: 07/29/2026
PlatyPS schema version: 2024-05-01
title: Update-MinecraftServer
---

# Update-MinecraftServer

## SYNOPSIS

Updates a configured Minecraft server.

## SYNTAX

### __AllParameterSets

```
Update-MinecraftServer [-ServerName] <string> [-NoBackup]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Updates a minecraft server

## EXAMPLES

### EXAMPLE 1

Update-MinecraftServer -ServerName "MyServer"

## PARAMETERS

### -NoBackup

Specify if you don't want the command to backup the server before updating.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: False
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ServerName

The name of the configured server.
You will hahve set this when using Install-MinecraftServer

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

{{ Fill in the related links here }}

