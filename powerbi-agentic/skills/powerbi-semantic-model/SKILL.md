---
name: powerbi-semantic-model
description: Guide to develop Power BI Semantic Models. Use this skill when asked to connect to a semantic model for analysis or any development operation against a Power BI Semantic Model including (1) Creating new models or Direct Lake models, (2) Creating/editing measures using DAX, (3) Creating/editing tables and relationships, (4) Analyzing model best practices, (5) Deploying models to Fabric workspace, (6) Working with PBIP projects containing semantic models, (7) Troubleshooting DAX performance. Use for any semantic model development, modeling guidelines, or DAX-related tasks.
---

# Power BI Semantic Model Skill

This skill provides guidance on how to develop Power BI semantic models.

## IMPORTANT

- Check if the `powerbi-modeling-mcp` MCP Server is available. If it is, prefer to use it instead of editing or creating *.tmdl files directly. 
- Remember that you can use the MCP tools against local TMDL folder by using the `database_operations` tool with `ConnectFolder` operation.

## Task: Connect to an existing semantic model

A semantic model can be loaded from the following locations: 

- **Power BI Desktop**: Use the MCP server tools to find the Power BI Desktop local instance and connect to it.
- **Fabric workspace**: Use the MCP server tools to connect to the semantic model in the workspace, make sure to use the exact workspace and semantic model name. Or use the Fabric CLI (`fab`) to export the semantic model code.
- **Power BI Project files (PBIP)**: Use the MCP server tools to connect to the PBIP folder.

## Task: Create a new semantic model

- Create a new empty semantic model database with compatibility level 1604 or higher. 
- Ensure you get a good understanding of user intent and data sources before executing the developments

## Task: Create a new Direct Lake model

- Connect to the OneLake data sources (e.g. Lakehouse) and understand the schema. If you don't have any specific OneLake tools, you can use the `fabric-cli` skill to explore the OneLake data.
- Use the Power BI Modeling MCP Server to create a new offline database with compatibility level 1604 or higher
- Using the schema from the lakehouse add the semantic model tables using EntitySourcePartition (see [direct-lake-guidelines](references/direct-lake-guidelines.md)) 
- Follow modeling guidelines in [modeling-guidelines](references/modeling-guidelines.md)
 
## Task: Execute a semantic model development

- Refer to [modeling-guidelines](references/modeling-guidelines.md) file for modeling guidelines.
- Make sure you understand the data sources of the model and if they are suitable for a star-schema. 
  - If the data source is Fabric OneLake (e.g. Lakehouse) you can use the Fabric CLI to analyze the table schemas.
- **IMPORTANT:** If its a Direct Lake semantic model refer to [direct-lake-guidelines](references/direct-lake-guidelines.md) file.
- Create the necessary relationships between the tables, specially when creating new tables.
- Create the measures that make sense for the intent, always following the modeling guidelines.
- When development is done, export the semantic model to a PBIP project (see [pbip.md](references/pbip.md))

## Task: Run Best Practice Analysis (BPA) rules

Run the script `scripts/bpa.ps1` against the semantic model if no specifuc BPA rules are mentioned use the default set of rules in `scripts/bpa-rules-semanticmodel.json`

**CRITICAL:** 
- If there is no semantic model in the context, prompt the user for the location of the semantic model.
- If the model is stored on your local file system, ensure you select a folder that contains either a database.tmdl, model.tmdl, or model.bim file.

```powershell
scripts/bpa.ps1 -models [path to the semantic model] -rulesFilePath [path to the BPA rules json file]
```

If the model is running in a local or remote server, call the script like this:

```powershell
scripts/bpa.ps1 -models [server:port database] -rulesFilePath [path to the BPA rules json file]
```

Report findings with severity levels (Critical, High, Medium, Info)

## Task: Deploy a semantic model code to Fabric Workspace

Two options:
- Option 1 (preferable): deploy using the MCP server
- Option 2: deploy using the CLI. Keep in mind that the source code must follow the PBIP format (see [pbip.md](references/pbip.md))

## Task: Open Semantic Model from PBIP

**CRITICAL:** Make sure you understand the PBIP structure in [pbip.md](references/pbip.md).

When asked to open/load the semantic model from a PBIP, you must only load the `[Name].SemanticModel/definition` folder that includes the TMDL code of the semantic model.

## Task: Save to PBIP

**CRITICAL:** Make sure you understand the PBIP structure in [pbip.md](references/pbip.md).

When asked to save the semantic model to a new PBIP folder make sure you create the folder and files from the structure above using the provided examples and serialize the model database to the `[Name].SemanticModel/definition` folder.

## References

**External references** (request markdown when possible):

- [Lineage tags for Power BI semantic models](https://learn.microsoft.com/en-us/analysis-services/tom/lineage-tags-for-power-bi-semantic-models?view=sql-analysis-services-2025)