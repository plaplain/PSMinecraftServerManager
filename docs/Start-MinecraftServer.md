---
document type: cmdlet
external help file: MinecraftServerManager-Help.xml
HelpUri: ''
Locale: en-US
Module Name: MinecraftServerManager
ms.date: 07/31/2026
PlatyPS schema version: 2024-05-01
title: Start-MinecraftServer
---

# Start-MinecraftServer

## SYNOPSIS

Starts a configured Minecraft server.

## SYNTAX

### __AllParameterSets

```
Start-MinecraftServer [-ServerName] <string> [-InterativeMode]
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Starts a Minecraft server using the configured server name.

## EXAMPLES

### EXAMPLE 1

Start-MinecraftServer -ServerName 'MyServer'

## PARAMETERS

### -InterativeMode

Run in an interactive mode where you can see the server console.

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

The server name you used when running Install-MinecraftServer

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

