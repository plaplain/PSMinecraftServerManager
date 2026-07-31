---
document type: cmdlet
external help file: MinecraftServerManager-Help.xml
HelpUri: ''
Locale: en-US
Module Name: MinecraftServerManager
ms.date: 07/31/2026
PlatyPS schema version: 2024-05-01
title: Backup-MinecraftServer
---

# Backup-MinecraftServer

## SYNOPSIS

Backs up a configured Minecraft server

## SYNTAX

### __AllParameterSets

```
Backup-MinecraftServer [-ServerName] <string>
```

## ALIASES

This cmdlet has the following aliases,
  {{Insert list of aliases}}

## DESCRIPTION

Backs up your configured Minecraft server to the Backup folder in the installation directory.

## EXAMPLES

### EXAMPLE 1

Backup-MinecraftServer -ServerName "MyServer"

## PARAMETERS

### -ServerName

The name of the server, this is the same name you used when running Install-MinecraftServer.

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

