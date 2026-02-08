# Direct Lake Modeling Guidelines

## Important

- Direct Lake semantic models main particularity is the use of DirectLake partitions. For regular modeling guidelines make sure to follow the [modeling-guidelines](references/modeling-guidelines.md).
- Before creating any Direct Lake table, make sure there is a named expression targeting the OneLake source. 
- ALL Direct Lake table partitions use partition source type `EntityPartitionSource` targeting an entity in OneLake and use the shared named expression with the OneLake data source. Do not attempt to use Power Query expressions in entity based tables. See [partition configuration](#partition-configuration) for configuration details of a Direct Lake mode partition. 
- That expression will be used in the tables partition `expressionSourceName` property.
- Columns with `dataType` `binary` are not supported. If they exist in the datasource do not include them in the model.
- Direct Lake tables must still declare the tables, but directly mapping to the columns in the OneLake table using the `sourceColumn` property

## Process to create a direct lake model

- Create a named expression for the Direct Lake connection to the OneLake source using the `AzureStorage.DataLake` connector. Do not use the `Sql.Database` unless explicitly asked for.
- Analyze the schema of the tables in OneLake
- Create tables with columns and types matching the OneLake tables and using `EntityPartitionSource` type for the partition.
- If there is a development workspace, deploy to it to test

## Partition Configuration

| Property | Value | Description |
|----------|-------|-------------|
| Source Type | `EntityPartitionSource` | Not `MPartitionSource` (no M/Power Query) |
| Mode | `DirectLake` | Required for Direct Lake partitions |
| entityName | String | Table name in data source |
| schemaName | String (optional) | Schema name (if data source supports it) |
| expressionSource | String | Reference to shared named expression |

**PowerQuery of the OneLake Data Source Named Expression**

Expression name: `DirectLake - [Model Name]`

```powerquery
let
    Source = AzureStorage.DataLake("https://onelake.dfs.fabric.microsoft.com/[WORKSPACE_ID]/[LAKEHOUSE_ID]", [HierarchicalNavigation=true])
in
    Source
```

## TMDL example of a Direct Lake table configuration

```tmdl

expression 'DL_Sales_Named_Expression' =
		let
		    Source = AzureStorage.DataLake("https://onelake.dfs.fabric.microsoft.com/[WORKSPACE_ID]/[LAKEHOUSE_ID]", [HierarchicalNavigation=true])
		in
		    Source
	lineageTag: eb1e4d8c-93d6-4e6f-ab86-8c059c8a898d

table Product
	lineageTag: 565d9d31-fe70-4fad-b5dc-3a034249ec80
	sourceLineageTag: [dbo].[product]

	column 'Product Key'
		dataType: int64
		formatString: 0		
		lineageTag: da696d24-5731-44f9-8b5d-496d11028855	
		sourceColumn: product_key		

	column Product
		dataType: string		
		lineageTag: 2de746d0-b547-4e94-aded-a0348d5e135d				
		sourceColumn: product

	column Category
		dataType: string		
		lineageTag: a0abb7b3-c828-4fc9-9206-36404f7eee0e		
		summarizeBy: none
		sourceColumn: category

	column UnitPrice
		dataType: decimal				
		lineageTag: 7f26a65f-624b-4f37-aaf6-6bd283191c6c		
		summarizeBy: none
		sourceColumn: Unit_Price

	partition partition_name = entity
		mode: directLake
		source
			entityName: Product
			schemaName: dbo
			expressionSource: DL_Sales_Named_Expression
```