# Power BI Semantic Model Modeling Guidelines

This document describes the modeling guidelines that should be applied when developing against a Power BI semantic model.

## Core Principles

- **Consistency Over Perfection** - When working with an existing semantic model, first analyze its established development patterns and align your work with them. 
- **Star schema modeling** - When modeling data, always default to a star schema: use a single fact table with denormalized dimension tables, clear one-column relationship keys, and one-to-many relationships. Only deviate if there is a strong, explicit requirement that a star schema cannot satisfy. Avoid snowflake dimensions.

## Naming Conventions

Apply the following naming convention only when creating new models. For existing models, it is preferable to remain consistent with the established naming convention, unless explicitly asked to evaluate consistency and propose a new one.

- Tables: business-friendly names, don't use terms as 'Fact' or 'Dim', use plural names for fact tables and singular names for dimension tables (e.g. `Sales`, `Product`, `Customer`). 
- Columns: Readable names with spaces (e.g. `Order Date`, `Product`, `Unit Price`)
- Columns: For dimension name prefer a column with the same name of the dimension. `Product` instead of `Product Name`
- Measures: clear naming patterns (`Total Sales`, `Total Quantity`, `# Customers`, `# Products`)
- Measures variations (e.g. time intelligence) should follow a consistent naming convention:
  - [measure name] for base measure
  - [measure name (ly)] for last year value of the base measure
  - [measure name (ytd)] for ytd value for the base measure
- **Critical**: Always use exact case-sensitive names when referencing objects
- **Verify names with List operations** before any update/rename operations

## Tables

At its core, a semantic model table consists of:
- Columns
- Measures
- Partitions (query to the data source)

**Table Creation Rules:**

**DO:**
- Start by creating the partition and the query to the data source. For Direct Lake models (see [Direct Lake Modeling Guidelines](direct-lake-guidelines.md)).
- Manually create all required columns with proper data types. The sourceColumn column property must map to the column name from the partition query.
- Default to M partition source type with import mode. Unless it's a Direct Lake Model.

**DON'T:**
- Use Power Query M code for tables with Direct Lake storage.
- Create shared named expressions for the table query


## Table partitions

Consider the following table to better understand partition types and storage modes:

| Partition source type                  | Storage mode                  | Typical usage                                                                                                                       |
| -------------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| M (MPartitionSource)                   | Import/DirectQuery            | Default type. The query uses Power Query (M code).                                                                                                           |
| Entity (EntityPartitionSource)         | DirectLake                    | There is no M expression. Used when it's connecting the semantic model table to a data source entity that can be a Lakehouse table. |
| Calculated (CalculatedPartitionSource) | Import                        | Used for calculated tables where the query is a DAX expression.                                                                                                      |

## Table Columns

**DO:**
- The `sourceColumn` property must map to the partition source expression.
- Ensure the `dataType` property is defined. Except for calculated tables where type can be inferred from the DAX expression.
  - Use efficient data types:
    - `Int64`: Keys and identifiers
    - `Decimal`: Currency and precise numbers
    - `String`: Text data
    - `DateTime`: Dates and timestamps
    - `Boolean`: True/false values
- Hide technical columns: `IsHidden = true`. Examples: ID columns, Foreign key columns, System columns.
- Disable summarization for non-aggregatable numerics: `SummarizeBy = None`. Examples: IDs, phone numbers, postal codes, year, month number, day of week
- Always refer to columns including the table name. For example: `'Table Name'[Column Name]`

**DON'T:**
- Use columns that don't map to a column in the partition source in both name and data type. 
  
## Measures & DAX

**DO:**
- Create explicit measures for aggregatable numeric columns. When creating a measure, make sure the numeric column is hidden and doesn't have the same name
- Distribute measures across relevant tables (avoid the single "Measures" table)
- Always set an appropriate `formatString` for the measure (see [Format String Reference](#format-string-reference))
- When creating a measure, if working against online database, test it with a simple query.
- Always refer to measures without including the table name. For example: `[Measure Name]`
- When creating complex DAX, use the `VAR` keyword to break into logical calculation steps. Prefix variables with `_` to avoid naming conflicts.

**DON'T:**
- Use implicit aggregations from numeric columns
- Store all measures in a single dedicated table
- Create untested measures
- Excessive `CALCULATE` nesting.
- Set `dataType`, measure data types are inferred from DAX expressions at runtime 

### Format String Reference

**Standard Format Strings:**

| Format Type | Format String | Example Output | Notes |
|-------------|---------------|----------------|-------|
| Currency | `"\\$#,##0.00"` | $1,234.56 | Note double backslash (`\\`) |
| Percentage | `"0.00%"` | 45.67% | Two decimal places |
| Integer | `"#,##0"` | 1,234 | No decimal places |
| Decimal | `"#,##0.00"` | 1,234.56 | Two decimal places |
| Thousands | `"#,##0,K"` | 1,234K | Abbreviated |
| Millions | `"#,##0,,M"` | 1.23M | Abbreviated |
| No Decimals | `"0"` | 1234 | No thousands separator |
| One Decimal | `"#,##0.0"` | 1,234.5 | One decimal place |

**Special Characters:**
- `#` = Optional digit
- `0` = Required digit
- `,` = Thousands separator
- `.` = Decimal separator
- `%` = Percentage multiplier
- `\\` = Escape character (required before `$` and other special chars)

## Relationships

**DO:**
- Create relationships before measures (measures may reference them)
- Default to single-directional: `CrossFilteringBehavior = "OneDirection"`
- Prefer integer keys over string keys (performance optimization)
- Set `isKey = true` on the key column of the table. Each dimension must have exactly ONE unique key column

**DON'T:**
- Use Composite keys. They are NOT supported. 
- Do NOT create surrogate keys on Fact tables (memory waste)

## Date/Calendar Table

A Date/Calendar table is required for time-intelligence calculations such as Last Year or Year-To-Date.

**DO:**
- Use existing date table from data source (preferred).
- Create DAX calculated date table only if source table unavailable.
- Ensure contiguous date range (no gaps)
- Set the `dataCategory` property to "Time" for calendar tables.
- Ensure the common date attributes exist: Year, Quarter, Month, Day, Week (optional: Day of Week, Month Name)
- Configure the `sortByColumn` is set for text attributes such as "Month Name"

**DON'T:**
- Create a calendar table if there is a calendar table in the data source. Import that instead.

## Parameters

Semantic Model parameters are commonly used to parameterize data source URLs, server names, database names, or storage accounts. Enables seamless CI/CD without editing M code of each table.

**DO:**
- Use parameters to centralize the data source location instead of duplicating the reference on each table. Examples: `ServerName`, `DatabaseName`
- Parameters are a named expression that can be referenced in Power Query M code.

**DON'T:**
- Change existing models to use parameters unless asked by the user.

**Example of semantic model using parameters:**

```tmdl
expression Server = "Server01" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]
expression Database = "Server01" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

ref table TableName

		partition PartitionName = m
			mode: import
			source =
					let
					    Source = Sql.Database(#"Server", #"Database")~
                        ...

```

