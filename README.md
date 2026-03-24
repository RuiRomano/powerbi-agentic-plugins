# 🧩 Power BI Agentic Plugins

Plugins that turn GitHub Copilot into a specialist for Power BI and Microsoft Fabric development. Built for [GitHub Copilot CLI](https://github.com/features/copilot/cli) and [Claude Code](https://claude.com/product/claude-code), also compatible with [VS Code](https://code.visualstudio.com/).

## 📦 Plugins

| Plugin                           | What it does                                                                                                                      | 
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | 
| **[powerbi](./plugins/powerbi)** | Create semantic models, author reports in PBIR, write DAX queries, explore published datasets, and apply modeling best practices. | 
| **[fabric](./plugins/fabric)**   | Navigate workspaces, import/export item definitions, call Fabric & Power BI REST APIs, run jobs, and manage OneLake files.        | 

Every plugin follows the same structure:

```
plugin-name/
├── .claude-plugin/plugin.json   # Manifest
├── .mcp.json                    # Tool connections
├── agents/                      # Agent personas with role-specific instructions
└── skills/                      # Domain knowledge Copilot draws on automatically
```

- **Skills** encode domain expertise, best practices, command references, and step-by-step workflows. Copilot draws on them automatically when relevant.
- **Agents** define personas with specific responsibilities (e.g., a Power BI architect vs. developer) and declare which skills and tools to use.
- **Connectors** wire Copilot to external tools — the Fabric CLI and Power BI Modeling MCP — via [MCP servers](https://modelcontextprotocol.io/).

**These plugins are starting points.** They become much more useful when you customize them for how your team actually works:

- **Add company context** — Add your naming conventions, workspace structure, and modeling patterns into skill files so Copilot understands your world.
- **Adjust workflows** — Modify skill instructions to match how your team does things (e.g., your deployment pipeline, your BPA rules).
- **Swap connectors** — Edit `.mcp.json` to point at your specific MCP servers.
  
## 🚀 Getting Started

Select your AI assistant and install the plugin or skills directly within it.

### GitHub Copilot CLI Setup

- Install [GitHub Copilot CLI](https://github.com/features/copilot/cli)
- Open Copilot and run the following commands:

    ```bash
    # Open GitHub Copilot CLI
    copilot

    # Add the marketplace (one-time setup)
    /plugin marketplace add RuiRomano/powerbi-agentic-plugins

    # Install plugins
    /plugin install powerbi@powerbi-agentic-plugins
    /plugin install fabric@powerbi-agentic-plugins

    # Restart Copilot to activate
    ```

Once installed, plugins activate automatically. Skills fire when relevant — for example, asking Copilot to create a semantic model automatically pulls in the `powerbi-semantic-model` skill.

### Visual Studio Code Setup

- Install [Visual Studio Code](https://code.visualstudio.com/download)
- Install [GitHub Copilot Chat extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)
- Enable [Agent Skills](vscode://settings/chat.useAgentSkills) and [Use Skill Adherence Prompt](vscode://settings/chat.experimental.useSkillAdherencePrompt) in user settings (Ctrl+,)
- Follow [discover and install plugins](https://code.visualstudio.com/docs/copilot/customization/agent-plugins#_discover-and-install-plugins) to install this plugin in VS Code.
- Optionally, you can also clone/download this repo and manually setup in your workspac
    - Copy the skills you want from the downloaded plugin repo (e.g. `plugins\powerbi\skills`) to `.github/skills` 

        Your folder structure should look like this:

        ```text
        Folder/
        ├── .github/
        │   └── skills/
        │       └── powerbi-semantic-model/
        │           └── SKILL.md
        ├── ...
        ```

        See [GitHub Agent Skills documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills) for more information where you can configure skills with VS Code.


## 📊 Scenarios

### New Direct Lake semantic model on top of Lakehouse tables

```
# 1. Create a Lakehouse in Microsoft Fabric
# 2. Load it with some sample data, e.g. Retail sample data
# 3. Prompt:
    Create a new direct lake semantic model in workspace [workspace] that uses the tables from lakehouse [lakehouse]
```

### Semantic Model on top of CSV data

```
# Prompt:
    Create a new semantic model based on the CSV files located in `https://github.com/RuiRomano/powerbi-agentic-plugins/tree/main/assets/sample-data` use Power Query HTTP connector. Apply standard modeling best practices throughout (e.g., proper relationships, naming conventions, data types, and star schema design).
    After creating the semantic model, create a Power BI report on top of it.
```

### Align Report visuals

- Save a report as PBIP
- Close Desktop
- Open the PBIP using Copilot CLI
- Run the prompt
- Reopen PBIP in Power BI Desktop

```
# Prompt:
    Align the Power BI report visuals in the PBIR folder `Path to the PBIP *.Report\ folder`
    
```

### Spec driven development

- Create a Fabric workspace
- Using the [powerbi-architect](plugins/powerbi/agents/powerbi-architect.agent.md) agent
- Run the prompt below
- Using the [powerbi-developer](plugins/powerbi/agents/powerbi-developer.agent.md) agent ask to implement the spec created by the architect agent

Prompt:
```
## Goals

- Work in Fabric workspace: '[Workspace name]'
- I want to create a new Power BI semantic model with name 'SM_Sales_GitHub'
- CSV files are in the URL: https://github.com/RuiRomano/powerbi-agentic-plugins/tree/main/assets/sample-data
- **Business requirements:**
  - I want to see the total sales amount so that I can understand revenue performance.
  - I want to understand the taxes impact
  - I want to see year-over-year and month-over-month sales growth percentages  
- Ensure my **Team modeling guidelines are respected**. See [team-modeling-rules.md](assets/team-modeling-rules.md)
- **Before implementation create a spec for review**
  
## Expectations

- Model deployed to the Fabric workspace
- Model should be refreshed 
- Measures return expected results with acceptable performance

## Other
- When analysing CSV files from GitHub don't use the fetch_webpage. Download the files locally to a temp folder (`temp/`) and analyze the top ~50 rows without loading the entire file to LLM context window.
    
```

## Acknowledgments

The `fabric` plugin includes the `fabric-cli` skill by [Kurt Buhler](https://github.com/data-goblin), originally from [fabric-cli-plugin](https://github.com/data-goblin/fabric-cli-plugin).

## No Warranty / Limitation of Liability

This software is provided "as is" without warranties or conditions of any kind, either express or implied. Microsoft shall not be liable for any damages arising from use, misuse, or misconfiguration of this software.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [open@microsoft.com](mailto:open@microsoft.com) with any additional questions or comments.
