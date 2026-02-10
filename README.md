# powerbi-agentic-development

## Setup

### For Copilot CLI

**Install Power BI Modeling MCP**

- Download the [Power BI Modeling MCP](https://github.com/microsoft/powerbi-modeling-mcp?tab=readme-ov-file#manual-install)
- Open Copilot CLI
- Run the `/mcp add` command and fill the details:
    - name: powerbi-modeling-mcp
    - type: stdio
    - command: [path to mcp server download folder]\powerbi-modeling-mcp.exe --start

**Install plugins**

```

# Install powerbi-plugins
/plugin marketplace add RuiRomano/powerbi-plugins
/plugin install powerbi@powerbi-plugins

```

### For VS Code GitHub Copilot chat

Install the plugins using Copilot CLI or download the repo skills to a folder of your choice.

Configure [VS Code skills](vscode://settings/chat.agentSkillsLocations) to the skill folder:

![vs-code-settings-skills](assets/images/vs-code-settings-skills.png)

## Scenarios

TODO

## No Warranty / Limitation of Liability

This software is provided “as is” without warranties or conditions of any kind, either express or implied. Microsoft shall not be liable for any damages arising from use, misuse, or misconfiguration of this software.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [open@microsoft.com](mailto:open@microsoft.com) with any additional questions or comments.
