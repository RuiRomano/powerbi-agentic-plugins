---
name: powerbi-semantic-model
description: Guide to develop Power BI Semantic Models. Use this skill when asked to connect to a semantic model for analysis or any development operation against a Power BI Semantic Model including (1) Creating new models or Direct Lake models, (2) Creating/editing measures using DAX, (3) Creating/editing tables and relationships, (4) Analyzing model best practices, (5) Deploying models to Fabric workspace, (6) Working with PBIP projects containing semantic models, (7) Troubleshooting DAX performance. Use for any semantic model development, modeling guidelines, or DAX-related tasks. Do NOT use for report layout/visual authoring (use powerbi-pbir), TMDL syntax-only questions (use powerbi-tmdl), or workspace/pipeline administration (use fabric-cli).
---

# Power BI Semantic Model Skill

This skill provides guidance on how to develop Power BI semantic models.

## IMPORTANT

- Check if the `powerbi-modeling-mcp` MCP Server is available. If it is, prefer to use it instead of editing or creating *.tmdl files directly. 
- Remember that you can use the MCP tools against local TMDL folder by using the `database_operations` tool with `ConnectFolder` operation.
- If asked to export or save the semantic model to a PBIP project, make sure you follow the PBIP structure explained in [pbip.md](references/pbip.md).

## Tool Selection Priority

When deciding which tool to use for semantic model operations, follow this priority order:

1. **MCP Server available** → Use `powerbi-modeling-mcp` tools for all operations (create, edit, deploy, query) both against server or local folders.
2. **MCP Server unavailable + PBIP folder exists** → Edit TMDL files directly (defer to `powerbi-tmdl` skill for syntax rules).
3. **MCP Server unavailable + Fabric workspace** → Use `fabric-cli` skill to export the model, edit the TMDL files locally, then re-deploy.
4. **MCP Server unavailable + Power BI Desktop** → Guide the user to save as PBIP folder or enable the MCP server.

## Relationship to Other Skills

- **powerbi-tmdl**: Use for TMDL syntax rules when editing `.tmdl` files directly. This skill (`powerbi-semantic-model`) handles the higher-level modeling workflow and decision-making.
- **fabric-cli**: Use for workspace operations, deploying, and exploring OneLake data sources.
- **powerbi-pbir**: Use when the user also needs a report alongside the semantic model.

## Pre-development: Understand the Model

Before making any changes to an existing model, always gather context first:

1. **List all tables** — Understand the existing tables and their storage modes (Import, DirectQuery, Direct Lake).
2. **List existing relationships** — Map out the current star schema structure.
3. **List existing measures** — Avoid creating duplicates and understand existing calculation patterns.
4. **Check naming conventions** — Identify established patterns so new objects remain consistent (Consistency Over Perfection principle from [modeling-guidelines](references/modeling-guidelines.md)).
5. **Identify model type** — Determine if the model is Import, DirectQuery, Direct Lake, or Composite. This dictates which partition types and guidelines apply.

## Task: Connect to an existing semantic model

A semantic model can be loaded from the following locations:

1. **Power BI Desktop**: Use the MCP server tools to find the Power BI Desktop local instance and connect to it.
2. **Fabric workspace**: Use the MCP server tools to connect to the semantic model in the workspace, make sure to use the exact workspace and semantic model name. Or use the Fabric CLI (`fab`) to export the semantic model code.
3. **Power BI Project files (PBIP)**: Use the MCP server tools to connect to the PBIP folder.

After connecting, always run the **Pre-development** discovery steps above to understand the model before making changes.

## Task: Create a new semantic model

1. **Gather requirements** — Ask the user for: purpose of the model, data source type (SQL Server, Lakehouse, etc.), and key business entities/facts to model.
2. **Determine model type** — If the data source is Fabric OneLake → Direct Lake (see [Task: Create a new Direct Lake model](#task-create-a-new-direct-lake-model)). Otherwise → Import mode.
3. **Create the database** — Create a new empty semantic model database with compatibility level 1604 or higher.
4. **Create data source parameters** — (Skip for Direct Lake) Create semantic model M parameters for the data sources (`Server`, `Database`, etc.), and use them in the partition M code. This makes it easier to rebind the model and helps with deployments.
5. **Analyze source schema** — Use MCP tools or Fabric CLI to inspect the source tables, columns, and data types.
6. **Design star schema** — Identify fact and dimension tables, define relationship keys. Follow [modeling-guidelines](references/modeling-guidelines.md).
7. **Create tables** — Add partitions with correct source type, create columns with proper data types and `sourceColumn` mapping.
8. **Create relationships** — Define relationships between fact and dimension tables before creating measures.
9. **Create measures** — Add explicit measures for aggregatable columns. Follow DAX guidelines in [modeling-guidelines](references/modeling-guidelines.md).
10. **Validate** — Run BPA rules against the model (see [Task: Run Best Practice Analysis](#task-run-best-practice-analysis-bpa-rules)). Test measures with simple DAX queries.
11. **Save/Deploy** — Export to PBIP project or deploy to workspace.

## Task: Create a new Direct Lake model

1. **Connect to OneLake** — Connect to the OneLake data sources (e.g. Lakehouse) and understand the schema. If you don't have specific OneLake tools, use the `fabric-cli` skill to explore the OneLake data.
2. **Create database** — Use the Power BI Modeling MCP Server to create a new offline database with compatibility level 1604 or higher.
3. **Create the named expression** — Create a shared named expression for the Direct Lake connection using `AzureStorage.DataLake` connector (see [direct-lake-guidelines](references/direct-lake-guidelines.md)).
4. **Create tables** — Using the schema from the lakehouse, add semantic model tables using `EntityPartitionSource` with `directLake` mode. Map columns to the OneLake table columns.
5. **Create relationships and measures** — Follow [modeling-guidelines](references/modeling-guidelines.md).
6. **Validate** — Run BPA rules. If there is a development workspace, deploy to it to test.
 
## Task: Edit an existing semantic model

Use this workflow when the user wants to add/modify/remove measures, tables, columns, or relationships in an existing model.

1. **Connect to the model** — Determine source (PBIP folder, Desktop, Fabric workspace) and connect via MCP or locate the TMDL files.
2. **Run Pre-development discovery** — Follow the [Pre-development](#pre-development-understand-the-model) steps to understand the current model state.
3. **Plan changes** — Based on the user request, identify exactly what needs to be added, modified, or removed. Check for naming conflicts and duplicates.
4. **Determine model type** — **IMPORTANT:** If it's a Direct Lake semantic model, refer to [direct-lake-guidelines](references/direct-lake-guidelines.md). Otherwise, follow [modeling-guidelines](references/modeling-guidelines.md).
5. **Execute changes** — Apply modifications:
   - If adding tables: create partitions first, then columns, then relationships, then measures.
   - If adding measures: verify referenced columns/tables exist, test with a simple DAX query.
   - If adding relationships: ensure key columns exist on both sides with matching data types.
   - If the data source is Fabric OneLake, you can use the Fabric CLI to analyze the table schemas.
6. **Validate** — Run the [Post-development validation](#post-development-validate-changes) steps.
7. **Save** — If PBIP source, export to PBIP (see [pbip.md](references/pbip.md)). If online, save to workspace.

## Post-development: Validate Changes

After any model modification, always verify your work:

1. **Check the PBIP structure** - If the model is sourced from a PBIP folder, ensure the folder structure and files are correct (see [pbip.md](references/pbip.md)).
2. **Run BPA rules** — Execute best practice analysis to catch common issues (see [Task: Run BPA](#task-run-best-practice-analysis-bpa-rules)).
3. **Test new measures** — For each new measure, run a simple DAX query to validate it returns expected results (e.g., `EVALUATE { [Measure Name] }`).
4. **Verify relationships** — For new relationships, confirm cardinality, cross-filter direction, and that key columns have matching data types.
5. **Verify table columns** — For new tables, confirm all columns have correct `sourceColumn` mapping and `dataType`.
6. **Check for duplicates** — Ensure no duplicate measures (same DAX expression) or orphan objects were introduced.

## Task: Run Best Practice Analysis (BPA) rules

Run the script `scripts/bpa.ps1` against the semantic model. If no specific BPA rules are mentioned, use the default set of rules in `scripts/bpa-rules-semanticmodel.json`.

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

Report findings with severity levels (Critical, High, Medium, Info).

## Task: Deploy a semantic model code to Fabric Workspace

### Option 1: MCP Server (preferred)
1. Ensure the model is loaded in MCP.
2. Use `database_operations` with `Deploy` operation.
3. Specify the target workspace and semantic model name.
4. Verify the deployment succeeded by listing the workspace items.

### Option 2: Fabric CLI
1. Ensure the model is saved in PBIP format (see [pbip.md](references/pbip.md)).
2. Use the `fabric-cli` skill to deploy the semantic model item to the target workspace.
3. Verify the item appears in the workspace.

## Task: Refactor Measures Using DAX UDFs to Centralize and Reuse Business Logic

Load [DAX-UDF-Functions](references/DAX-UDF-Functions.md) to understand how to create and use DAX User-Defined Functions (UDFs).

1. Make sure you understand the pattern to be included in the UDF function definition, including the use of type hints, parameter modes, and AnyRef for references.
2. Create the UDF function
3. Refactor existing measures to call the UDF instead of containing duplicated logic.

## Task: Open Semantic Model from PBIP

**CRITICAL:** Make sure you understand the PBIP structure in [pbip.md](references/pbip.md).

When asked to open/load the semantic model from a PBIP, you must only load the `[Name].SemanticModel/definition` folder that includes the TMDL code of the semantic model.

## Task: Save to PBIP

**CRITICAL:** Make sure you understand the PBIP structure in [pbip.md](references/pbip.md).

When asked to save the semantic model to a new PBIP folder make sure you create the folder and files from the structure above using the provided examples and serialize the model database to the `[Name].SemanticModel/definition` folder.

## Error Handling

- **MCP connection failure**: Fall back to direct TMDL file editing (see Tool Selection Priority). Inform the user about the fallback.
- **TMDL validation errors**: Read the error details, fix the specific property or syntax issue, and re-validate.
- **Deployment failure**: Check workspace permissions, model compatibility level, and Direct Lake expression source references.
- **DAX errors in measures**: Test measures individually. Check column and table name references — they are case-sensitive. Verify referenced objects exist.
- **Missing data source**: If the partition source cannot be resolved, verify M parameters or named expressions are correctly defined.

## References

**External references** (request markdown when possible):

- [Lineage tags for Power BI semantic models](https://learn.microsoft.com/en-us/analysis-services/tom/lineage-tags-for-power-bi-semantic-models?view=sql-analysis-services-2025)