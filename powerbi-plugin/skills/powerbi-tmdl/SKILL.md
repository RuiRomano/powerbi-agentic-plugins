---
name: powerbi-tmdl
description: Guide to develop against TMDL files or TMDL code. Use this skill when asked to change TMDL code or files (*.tmdl). Includes creating measures with DAX, setting descriptions, working with Power Query M code in partitions, creating RLS roles, and exporting semantic models to TMDL format. Use for any direct manipulation of TMDL syntax or Power BI semantic model definition files.
---

# TMDL code Skill

Tabular Model Definition Language (TMDL) is a declarative language that represents a Power BI semantic model in text. This skill provides important context when interacting directly with TMDL code.

## TMDL Semantics / General Rules

- A TMDL object is declared by specifying the TOM object type followed by its name
- TMDL definition uses a folder structure, where some objects such as tables, culture, perspectives, roles are defined in separate files.
- Objects like partition or measure have default properties that can be assigned after the equals (=) sign that specify the PowerQuery expression or DAX expression respectively.

**DO:**
- Always learn from existing examples and patterns in the code. For example, existing naming conventions.
- Object names must be enclosed in single quotes if they contain spaces or special characters such as .,=,:,'

**DON'T:**
- Don't add `lineageTag` property when creating new objects
- Don't add comments to the TMDL code. TMDL language don't support `//` comments. It does support descriptions (see [Task: Setting descriptions in TMDL objects](#task-setting-descriptions-in-tmdl-objects)). But comments can be within Power Query (M) expressions or DAX expressions code blocks.    

Example of a TMDL of a semantic model:

```tmdl

model Model    
    culture: en-US  

    table Sales
        
        measure 'Total Amount' = SUM('Sales'[Amount])
            formatString: $ #,##0
    
        column 'Product Key'
            dataType: int64
            isHidden
            sourceColumn: ProductKey
            summarizeBy: None
    
        column Amount
            dataType: double
            isHidden
            sourceColumn: Amount
            summarizeBy: None

        ...

        partition 'Sales-Partition' = m
            mode: import
            source = 
                let
                    Source = Sql.Database(Server, Database)
                    …

    table Product
              
        column 'Product Key'
            dataType: int64
            isKey
            sourceColumn: ProductKey
            summarizeBy: none

        ...

        partition 'Product-Partition' = m
            mode: import
            source = 
                let
                    Source = Sql.Database(Server, Database),
                    …

    relationship cdb6e6a9-c9d1-42b9-b9e0-484a1bc7e123
        fromColumn: Sales.'Product Key'
        toColumn: Product.'Product Key'

```

## TMDL scripts

TMDL scripts are produced by TMDL view and are normally under the `TMDLScripts` folder of a semantic model.

A TMDL script always include a command in the top followed by one or more objects with at least one level of indentation.

```tmdl
<TMDL Command name>
  <TMDL object>
  
  <TMDL object>
```
- The semantics of TMDL language are applied to objects within the command 
- TMDL scripts only support one command today: `createOrReplace`


Example of a TMDL script of a table using `createOrReplace` command:

```tmdl
createOrReplace

    table Product

        measure '# Products' = COUNTROWS('Product')
            formatString: #,##0

        column 'Product Name'
            dataType: string

        ...
    
```

## TMDL table examples by storage mode

**Import table**
```tmdl
table customer	

	column customerId
		dataType: int64				
		sourceColumn: customerId		

	column customer
		dataType: string								
		sourceColumn: customer

	partition customer = m
		mode: import
		source =
				let
				    ...
				in
				    #"Final Step"
			
```

**Direct Lake table**
```tmdl
expression DatabaseQuery =
        let
            Source = AzureStorage.DataLake("https://onelake.dfs.fabric.microsoft.com/[WORKSPACE_ID]/[LAKEHOUSE_ID]", [HierarchicalNavigation=true])
        in
            Source

table customer	

	column customerId
		dataType: int64				
		sourceColumn: customerId		

	column customer
		dataType: string								
		sourceColumn: customer

	partition customer = entity
		mode: directLake
		source
			entityName: customer
			schemaName: dbo
			expressionSource: DatabaseQuery	
```


## Task: Export semantic model database to code format

Use the MCP tool to export the semantic model as TMDL code. Make sure you respect the PBIP file structure, see [pbip.md](../powerbi-semantic-model/references/pbip.md) for more details.

This is useful to use the Fabric CLI to import to a workspace.

## Task: Setting descriptions in TMDL objects

✅ **DO:**
- The format should be '/// Description' placed right above each object such as 'table, 'column', or 'measure' identifier in the TMDL code.
    ```tmdl    
    /// Description line 1
    /// Description line 2
    measure 'Measure1' = [DAX Expression]
        formatString: #,##0
    
    /// Description line 1
    column 'Column1'
        formatString: #,##0
        dataType: string
    ```
- Ensure comments provide clear explanations of the definitions and purpose of the table, column or measure, incorporating **COMPANY** business and data practices where applicable.
- Enhance existing descriptions but use them as baseline.
- Use concise and meaningful descriptions that align with the purpose of the measure or column.

❌ **DON'T:**
- Don't use the `description` property:
  ```tmdl
    measure 'Measure1' = [DAX Expression]
        formatString: #,##0
        description: 'Description line 1 Description line 2'
  ```
- Don't change any other property while inserting descriptions


## Task: Creating measures in TMDL
- Always include a formatString property appropriate for the measure type.
- Always include a description following the rules from **Setting descriptions in TMDL objects** section.
- Don't create measures for non aggregatable columns such as keys or descriptions. Unless they specify a summarizeBy property different than 'none'
- Don't create complex DAX. Keep it simple, most of the times I'm just trying to save some time for basic stuff.
- Multi-line DAX expression should be enclosed within ```
- The DAX expression should appear after the measure name preceeded with the '=' sign.
- If its a single line DAX expression add it immediately after the measure name and '=' sign.
- Measures should go to the top of the table object, before any column declaration.

    Example:

    ```tmdl   
    table TableName

        /// Description measure 1
        measure 'Measure 1' = [Single Line DAX]
            formatString: #,##0

        /// Description measure 2
        measure Measure2 = ```
                [DAX Expression line 1
                DAX Expression line 2]
                ```
            formatString: #,##0

        column 'Product Name'
            dataType: string            
        
        ...

    ```

## Task: Create new Row Level Security (RLS) Roles

- If possible analyze the patterns of existing roles
- When creating new roles, never include the `PBI_Id` annotation

## Task: Setting descriptions in Power Query / M code in partition expressions

- You are an assistant to help Power Query developers comment their code.         
- Insert a comment above the code explaining what that piece of code is doing.
- Do not start the comment with the word Step or a number
- Do not copy code into the comment.
- Keep the comments to a maximum of 225 characters.
- Update the step name explaining what that piece of code is doing.
- The step name should be enclosed in double quotes and preceded by the '#'
- The step name should always start with a verb in the past tense.
- The step name should have spaces between words. 
- Keep the step name to a maximum of 50 characters.


## References

**External references** (request markdown when possible):

- [TMDL docs](https://learn.microsoft.com/en-us/analysis-services/tmdl/tmdl-overview)