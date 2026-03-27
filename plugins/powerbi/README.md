# Power BI

Power BI development plugin that connects AI agents to semantic models, reports, and Fabric workspaces — enabling design, development, and deployment of complete Power BI solutions.

## What it does

Activated when a user needs to design, build, or maintain Power BI solutions. Covers the full development lifecycle from architecture and data modeling to report authoring, DAX optimization, and deployment to Microsoft Fabric.

|  |  |
|--|--|
| Semantic model development | "Create a star schema model from this CSV data" |
| DAX measures | "Add a Year-over-Year growth measure to the Sales table" |
| Direct Lake models | "Set up a Direct Lake semantic model pointing to my lakehouse tables" |
| DAX performance | "Why is this measure slow? Optimize it for me" |
| Solution architecture | "Design a semantic model spec for my inventory data" |
| Deployment | "Deploy the semantic model to the Production workspace" |

## Agents

### `powerbi-developer`

Activated when a user needs to implement Power BI solutions — creating and editing semantic models, writing and optimizing DAX, building reports in PBIR format, and deploying to Fabric workspaces. Uses the `powerbi-semantic-model`, `powerbi-report`, and `fabric-cli` skills.

### `powerbi-architect`

Activated when a user needs to design a Power BI solution before implementation. Analyzes data sources, designs star schemas, and produces detailed spec documents (`specs/*.spec.md`) for the `powerbi-developer` agent to execute. Does not implement — only designs.

## Skills

### `powerbi-semantic-model-authoring`

Activated for any semantic model operation — creating or editing tables, measures, relationships, and hierarchies; writing DAX; configuring Direct Lake partitions; deploying models to Fabric; and working with TMDL files and PBIP projects.

### `powerbi-report-authoring`

Activated for any report operation — creating or editing Power BI reports in PBIR format, configuring visuals and pages, applying themes, rebinding reports to different semantic models, and deploying reports to Fabric workspaces.

## MCP server

The `powerbi-modeling-mcp` server provides a direct connection to a live Power BI semantic model running in Power BI Desktop. It exposes tools for querying model metadata, running DAX queries, and applying model changes — enabling agents to work with the model interactively without editing TMDL files manually.

The MCP server runs in-process with Power BI Desktop (requires the Analysis Services endpoint to be enabled).
