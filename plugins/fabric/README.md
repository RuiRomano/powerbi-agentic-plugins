# Fabric

Microsoft Fabric platform plugin that connects AI agents to Fabric workspaces, items, and APIs — enabling management, automation, and deployment across the entire Fabric ecosystem.

## What it does

Activated when a user needs to interact with Microsoft Fabric programmatically. Uses the `fab` CLI to perform operations across workspaces, items, lakehouses, notebooks, and REST APIs.

|  |  |
|--|--|
| Workspace management | "List all workspaces I have access to" |
| Item discovery | "What items are in my Production workspace?" |
| Export & import | "Export the Sales semantic model to a local folder" |
| Cross-workspace deployment | "Copy the ETL notebook from Dev to Prod" |
| Job execution | "Run the nightly refresh notebook and wait for it to finish" |
| OneLake file operations | "Upload this CSV to the lakehouse Files folder" |
| REST API calls | "Trigger a full refresh of the Sales dataset via the Power BI API" |

## Agents

### `fabric`

Activated for any Fabric platform task — managing workspaces, importing or exporting item definitions, running jobs, calling Fabric and Power BI REST APIs, and orchestrating deployments across environments. Uses the `fabric-cli` skill to drive the `fab` CLI.

## Skills

### `fabric-cli`

Activated when a user needs to run `fab` CLI commands to manage Fabric resources. Covers authentication, workspace and item listing, item import/export, job execution, OneLake file management, and direct calls to the Fabric, Power BI, and OneLake REST APIs.

## Prerequisites

- **Fabric CLI (`fab`)** — [Install from the Microsoft Fabric documentation](https://learn.microsoft.com/en-us/fabric/cli/fabric-cli)
- **Microsoft Fabric account** with access to at least one workspace
- **Authentication** — Run `fab auth login` before first use to authenticate with your Microsoft account
