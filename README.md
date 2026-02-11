# powerbi-agentic-plugins

## Pre-Requisites

- Install [Fabric CLI](https://microsoft.github.io/fabric-cli/)
- Install [Copilot CLI](https://github.com/features/copilot/cli)
- Download or Install [Power BI Modeling MCP](https://github.com/microsoft/powerbi-modeling-mcp)

## Copilot CLI setup

```
# 1. Open GitHub Copilot CLI
copilot

#2. Register the Power BI Modeling MCP
/mcp add
    - name: powerbi-modeling-mcp
    - type: stdio
    - command: [path to mcp server download folder]\powerbi-modeling-mcp.exe --start

#3. Register the marketplace (one-time setup)
/plugin marketplace add RuiRomano/powerbi-agentic-plugins

#4. Install plugins

/plugin install powerbi-plugin@powerbi-agentic-plugins
/plugin install fabric-plugin@powerbi-agentic-plugins

#5. Restart Copilot/mcp

```

Other helpful commands:
```
# Remove the marketplace and plugins

/plugin marketplace remove powerbi-agentic-plugins --force

# Update plugin to latest version

/plugin update powerbi-plugin
```

## VS Code setup

Configure [VS Code skills](vscode://settings/chat.agentSkillsLocations) to the skill folder:

![vs-code-settings-skills](assets/images/vs-code-settings-skills.png)

## Scenarios

### New Direct Lake semantic model on top of Lakehouse tables

```
# 1. Create a Lakehouse in Microsoft Fabric
# 2. Load it with some sample data, e.g. Retail sample data
# 3. Prompt the following in Copilot CLI:
> Create a new direct lake semantic model in workspace [workspace] that uses the tables from lakehouse [lakehouse]
```

### Semantic Model on top of CSV data

```
# Prompt the following in Copilot CLI:
Use the powerbi-semantic-model skill to create a new semantic model based on the CSV files located in \assets\sample-data. Apply standard modeling best practices throughout (e.g., proper relationships, naming conventions, data types, and star schema design). 
Using PBIR also create a sample report on top of the semantic model.
```

## No Warranty / Limitation of Liability

This software is provided “as is” without warranties or conditions of any kind, either express or implied. Microsoft shall not be liable for any damages arising from use, misuse, or misconfiguration of this software.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [open@microsoft.com](mailto:open@microsoft.com) with any additional questions or comments.
