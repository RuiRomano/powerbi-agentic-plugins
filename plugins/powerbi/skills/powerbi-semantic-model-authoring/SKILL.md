---
name: powerbi-semantic-model-authoring
description: Develops and manages Power BI Semantic Models. Handles connecting to semantic models for analysis and all development operations including (1) Creating new models, (2) Creating/editing measures using DAX, (3) Creating/editing tables and relationships, (4) Analyzing model best practices, (5) Deploying models to Fabric workspace, (6) Working with PBIP projects containing semantic models, (7) Troubleshooting DAX performance, (8) Refreshing semantic models in Desktop or Fabric service, (9) Creating or editing TMDL code or TMDL files. Does NOT handle report layout/visual authoring, or workspace/pipeline administration (use fabric-cli).
---

# Power BI Semantic Model Skill

This skill provides guidance on how to develop Power BI semantic models.

## References

- [modeling-guidelines](references/modeling-guidelines.md): General best practices for modeling, including star schema design, naming conventions, and DAX measure patterns.
- [direct-lake-guidelines](references/direct-lake-guidelines.md): Specific guidelines for working with Direct Lake semantic models, including partition source types and limitations.
- [TMDL](references/TMDL.md): Reference for TMDL syntax and properties when working with TMDL code and files.
- [pbip.md](references/pbip.md): Guidelines for working with Power BI Project files (PBIP) that contain semantic models.
- [dax-udf-functions-guidelines](references/dax-udf-functions-guidelines.md): Guidelines for creating and using DAX User-Defined Functions (UDFs) to centralize business logic in the model.
- [dax-query-guidelines](references/dax-query-guidelines.md): Guidelines for writing DAX queries against the semantic model for validation and analysis.
- [dax-performance-optimization](references/dax-performance-optimization.md): Guidelines for DAX performance optimization, including storage engine vs. formula engine analysis, anti-pattern detection, and optimization strategies.

## IMPORTANT

- Respect the [Tool Selection Priority](#tool-selection-priority).
- If asked to work with TMDL code or *.tmdl files, load the [TMDL reference](references/TMDL.md) to understand the syntax and properties of TMDL objects.
- If asked to export or save the semantic model to a PBIP project, make sure you understand the PBIP explained in [references/pbip.md](references/pbip.md).

## Tool Selection Priority

When deciding which tool to use for semantic model operations, follow this priority order:

1. **MCP Server available** → Use `powerbi-modeling-mcp` tools for all operations (create, edit, deploy, query) both against server or local folders. Unless the user specifically requests working with TMDL files.
2. **MCP Server unavailable + PBIP folder exists** → Edit TMDL files directly.
3. **MCP Server unavailable + Fabric workspace** → Use `fabric-cli` skill to export the model, edit the TMDL files locally, then re-deploy.
4. **MCP Server unavailable + Power BI Desktop** → Guide the user to save as PBIP folder or enable the MCP server.

## Relationship to Other Skills

- **fabric-cli**: Use for workspace operations, deploying, and exploring OneLake data sources.
- **powerbi-pbir**: Use when the user also needs a report alongside the semantic model.

## Pre-development: Understand the Model

Before making any changes to an existing model, always gather context first.

1. **List all tables** — Understand the existing tables and their storage modes (Import, DirectQuery, Direct Lake).
2. **List existing relationships** — Map out the current star schema structure.
3. **List existing measures** — Avoid creating duplicates and understand existing calculation patterns.
4. **Check naming conventions** — Identify established patterns so new objects remain consistent (Consistency Over Perfection principle from [modeling-guidelines](references/modeling-guidelines.md)).
5. **Identify model storage mode** — Determine if the model storage mode is Import, DirectQuery, Direct Lake, or Composite. This dictates which partition types and guidelines apply.

## Task: Edit or Create TMDL code or *.tmdl files

When working with TMDL code directly, follow these guidelines:

- Load the [TMDL](references/TMDL.md) reference to understand the syntax and properties of TMDL objects.
- Pay attention to the structure and indentation of the TMDL code, as it defines the hierarchy of objects (database > tables > columns/measures).

## Task: Connect to an existing semantic model

A semantic model can be loaded from the following locations:

1. **Power BI Desktop**: Use `powerbi-modeling-mcp` tools to find the Power BI Desktop local instance and connect to it.
2. **Fabric workspace**: Use `powerbi-modeling-mcp` tools to connect to the semantic model in the workspace, make sure to use the exact workspace and semantic model name. Or use the Fabric CLI (`fab`) to export the semantic model code.
3. **Power BI Project files (PBIP)**: Use `powerbi-modeling-mcp` tools to connect to the PBIP folder.

## Task: Create a new semantic model

1. **Gather requirements** — Ask the user for: purpose of the model, data source type (SQL Server, Lakehouse, etc.), and key business entities/facts to model.
2. **Determine model storage mode** — If the data source is Fabric OneLake > Direct Lake (see [Task: Create a new Direct Lake model](#task-create-a-new-direct-lake-model)). Otherwise > Import mode.
3. **Create the database** — Create a new empty semantic model database with compatibility level 1702 or higher.
4. **Create data source parameters** — (Skip for Direct Lake) Create semantic model M parameters for the data sources (`Server`, `Database`, etc.), and use them in the partition M code. This makes it easier to rebind the model and helps with deployments.
5. **Analyze source schema** — Use `powerbi-modeling-mcp` tools or Fabric CLI to inspect the source tables, columns, and data types.
6. **Design star schema** — Identify fact and dimension tables, define relationship keys. Follow [modeling-guidelines](references/modeling-guidelines.md).
7. **Create tables** — Add partitions with correct source type, create columns with proper data types and `sourceColumn` mapping.
8. **Create relationships** — Define relationships between fact and dimension tables before creating measures.
9. **Create measures** — Add explicit measures for aggregatable columns. Follow DAX guidelines in [modeling-guidelines](references/modeling-guidelines.md).
10. **Save/Deploy** — Export to PBIP project or deploy to workspace.

## Task: Create a new Direct Lake model

1. **Connect to OneLake** — Connect to the OneLake data sources (e.g. Lakehouse) and understand the schema. If you don't have specific OneLake tools, use the `fabric-cli` skill to explore the OneLake data.
2. **Create database** — Use the Power BI Modeling MCP Server to create a new offline database with compatibility level 1702 or higher.
3. **Create the named expression** — Create a shared named expression for the Direct Lake connection using `AzureStorage.DataLake` connector (see [direct-lake-guidelines](references/direct-lake-guidelines.md)).
4. **Create tables** — Using the schema from the lakehouse, add semantic model tables using `EntityPartitionSource` with `directLake` mode. Map columns to the OneLake table columns.
5. **Create relationships and measures** — Follow [modeling-guidelines](references/modeling-guidelines.md).
 
## Task: Edit an existing semantic model

Use this workflow when the user wants to add/modify/remove measures, tables, columns, or relationships in an existing model.

1. **Connect to the model** — Determine source (PBIP folder, Desktop, Fabric workspace) and connect via MCP or locate the TMDL files.
2. **Run Pre-development discovery** — Follow the [Pre-development](#pre-development-understand-the-model) steps to understand the current model state.
3. **Plan changes** — Based on the user request, identify exactly what needs to be added, modified, or removed. Check for naming conflicts and duplicates.
4. **Determine model storage mode** — **IMPORTANT:** If it's a Direct Lake semantic model, refer to [direct-lake-guidelines](references/direct-lake-guidelines.md). Otherwise, follow [modeling-guidelines](references/modeling-guidelines.md).
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
2. **Test new measures** — For each new measure, run a simple DAX query to validate it returns expected results (e.g., `EVALUATE { [Measure Name] }`).
3. **Verify relationships** — For new relationships, confirm cardinality, cross-filter direction, and that key columns have matching data types.
4. **Verify table columns** — For new tables, confirm all columns have correct `sourceColumn` mapping and `dataType`.
5. **Check for duplicates** — Ensure no duplicate measures (same DAX expression) or orphan objects were introduced.

If any check fails, fix the issue and re-run validation from step 1. Only proceed to Save when all checks pass.

## Task: Run Best Practice Analysis (BPA) rules

Run the script `scripts/bpa.ps1` against the semantic model. If no specific BPA rules are mentioned, use the default set of rules in `scripts/bpa-rules-semanticmodel.json`. The script runs the BPA rules using Tabular Editor 2.0.

This is specially useful when user wants to enforce static rules to ensure model consistency and adherence to best practices. For example, you can create custom BPA rules to check for specific naming conventions, required documentation, or to prevent certain anti-patterns in the model.

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

1. Ensure the model is loaded in MCP.
2. Use `powerbi-modeling-mcp:database_operations` with `Deploy` operation.
3. Specify the target workspace and semantic model name.
4. Verify the deployment succeeded by listing the workspace items.

If `powerbi-modeling-mcp` is unavailable, ensure the model is saved in PBIP format (see [pbip.md](references/pbip.md)) and use the `fabric-cli` skill to deploy.

## Task: Refresh a Semantic Model

Refresh is only possible when working against a live model in Power BI Desktop or Fabric Service. If working with local TMDL files, instruct the user to deploy the model to a workspace or open it in Power BI Desktop to enable refresh capabilities.

Determine the refresh target:

- **Power BI Desktop** -> Use `powerbi-modeling-mcp` Refresh tools to refresh individual tables or the entire model.
- **Fabric Service + MCP available** -> Connect to the semantic model in the workspace and use `powerbi-modeling-mcp` Refresh tools.
- **Fabric Service + no MCP** -> Use the Power BI Enhanced Refresh API (`POST /groups/{groupId}/datasets/{datasetId}/refreshes`) and poll the refresh status endpoint to check completion.

### Credential Configuration Errors (Service only)

If the refresh fails with an error indicating missing or invalid data source credentials **stop immediately** and instruct the user to configure the data source connections manually in Power BI Service.

Do not attempt to retry or work around credential errors programmatically.

## Task: Refactor Measures Using DAX UDFs to Centralize and Reuse Business Logic

Load [dax-udf-functions-guidelines](references/dax-udf-functions-guidelines.md) to understand how to create and use DAX User-Defined Functions (UDFs).

1. Make sure you understand the pattern to be included in the UDF function definition, including the use of type hints, parameter modes, and AnyRef for references.
2. Create the UDF function
3. Refactor existing measures to call the UDF instead of containing duplicated logic.

## Task: Query a semantic model using DAX

Before writing the DAX query, load [dax-query-guidelines](references/dax-query-guidelines.md) 

## Task: Optimize DAX measures for performance

Load [dax-performance-optimization](references/dax-performance-optimization.md) and follow the complete framework defined there. Requires the `powerbi-modeling-mcp` MCP Server connected to the target semantic model.

## Task: Open Semantic Model from PBIP

- Make sure you understand the PBIP structure in [pbip.md](references/pbip.md).
- Only load the `[Name].SemanticModel/definition` folder that includes the TMDL code of the semantic model.

## Task: Save or Export to PBIP

- Create a PBIP structure if it doesn't exist, following the guidelines in [pbip.md](references/pbip.md)
- Serialize the database definition to the `[Name].SemanticModel/definition` folder in TMDL format
- If there is no report folder, create a empty report folder with a minimal `definition.pbir` file that references the semantic model using `byPath` to the semantic model

## Error Handling

- **MCP connection failure**: Fall back to direct TMDL file editing (see Tool Selection Priority). Inform the user about the fallback.
- **TMDL validation errors**: Read the error details, fix the specific property or syntax issue, and re-validate.
- **Deployment failure**: Check workspace permissions, model compatibility level, and Direct Lake expression source references.
- **DAX errors in measures**: Test measures individually. Check column and table name references — they are case-sensitive. Verify referenced objects exist.
- **Missing data source**: If the partition source cannot be resolved, verify M parameters or named expressions are correctly defined.
- **Refresh credential error (service)**: If a service refresh fails due to missing or invalid credentials, stop and direct the user to configure gateway/cloud connections in the Power BI Service portal (see [Task: Refresh a Semantic Model](#task-refresh-a-semantic-model)).
