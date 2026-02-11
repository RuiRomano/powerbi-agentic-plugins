# Power BI Semantic Model Modeling Guidelines

This document describes the modeling guidelines that should be applied when developing against a Power BI semantic model.

## Core Principles

- **Consistency Over Perfection** - When working with an existing semantic model, first analyze its established development patterns and align your work with them. 
- **Star schema modeling** - When modeling data, always default to a star schema: use a single fact table with denormalized dimension tables, clear one-column relationship keys, and one-to-many relationships. Only deviate if there is a strong, explicit requirement that a star schema cannot satisfy. Avoid snowflake dimensions.
- **Explicit over implicit** - Always use explicit measures instead of relying on implicit aggregations. Hide aggregatable columns and create measures for them.
- **Lean models** - Only include columns and tables that are needed for analysis. Remove unused objects to keep the model small and fast.

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
- Object names must not contain tabs, line breaks, or other control characters
- Object names must not start or end with a space
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
- Add a `description` to tables to document their purpose and grain.
- Ensure every table has at least one relationship to another table in the model (except utility tables).

**DON'T:**
- Use Power Query M code for tables with Direct Lake storage.
- Create shared named expressions for the table query.
- Leave orphan tables disconnected from the model without a clear reason.


## Table partitions

Consider the following table to better understand partition types and storage modes:

| Partition source type                  | Storage mode                  | Typical usage                                                                                                                       |
| -------------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| M (MPartitionSource)                   | Import/DirectQuery            | Default type. The query uses Power Query (M code).                                                                                                           |
| Entity (EntityPartitionSource)         | DirectLake                    | There is no M expression. Used when it's connecting the semantic model table to a data source entity that can be a Lakehouse table. |
| Calculated (CalculatedPartitionSource) | Import                        | Used for calculated tables where the query is a DAX expression.                                                                                                      |

**Partition naming:** For single-partition tables, the partition name should match the table name.

## Table Columns

**DO:**
- The `sourceColumn` property must map to the partition source expression. Every data column must have a `sourceColumn`.
- Ensure the `dataType` property is defined. Except for calculated tables where type can be inferred from the DAX expression.
  - Use efficient data types:
    - `Int64`: Keys and identifiers
    - `Decimal`: Currency and precise numbers (limited to 4 decimal digits)
    - `String`: Text data
    - `DateTime`: Dates and timestamps
    - `Boolean`: True/false values
  - **Avoid `Double` (floating point)** — causes roundoff errors and degraded performance. Use `Decimal` or `Int64` instead.
- Hide technical columns: `IsHidden = true`. Examples: ID columns, Foreign key columns, System columns.
- Hide fact table columns that are aggregated in measures (the measure is the user-facing interface).
- Disable summarization for non-aggregatable numerics: `SummarizeBy = None`. Examples: IDs, phone numbers, postal codes, year, month number, day of week
- Set `isAvailableInMdx = false` on hidden columns that are not used as `SortByColumn`, not referenced in user hierarchies, and not used in variations. This saves memory and processing time.
- Set `dataCategory` for geographic columns (e.g., `City`, `Country`, `Continent` → `dataCategory: "City"`, `"Country"`, etc.) and for latitude/longitude columns.
- For flag/boolean columns (names starting with "Is" or ending with "Flag"), prefer `String` type with "Yes"/"No" values for readability, or keep as `Boolean`.
- Configure `sortByColumn` for text columns that need non-alphabetical sorting (e.g., month names sorted by month number).
- Always refer to columns including the table name. For example: `'Table Name'[Column Name]`

**DON'T:**
- Use columns that don't map to a column in the partition source in both name and data type.
- Use `Double` data type — use `Decimal` or `Int64` instead.
- Leave foreign key columns visible — always hide them.
  
## Measures & DAX

**DO:**
- Create explicit measures for aggregatable numeric columns. When creating a measure, make sure the numeric column is hidden and doesn't have the same name.
- Distribute measures across relevant tables (avoid the single "Measures" table).
- Always set an appropriate `formatString` for the measure (see [Format String Reference](#format-string-reference)).
- Add `description` to measures to explain business logic, especially for complex calculations.
- Use `displayFolder` to organize measures into logical groups within each table.
- When creating a measure, if working against online database, test it with a simple query.
- Always refer to measures without including the table name. For example: `[Measure Name]`
- When creating complex DAX, use the `VAR` keyword to break into logical calculation steps. Prefix variables with `_` to avoid naming conflicts.
- Use `DIVIDE()` function instead of `/` operator for division — it safely handles divide-by-zero by returning BLANK.
- Use `KEEPFILTERS()` or direct column predicates as `CALCULATE` filter arguments instead of wrapping `FILTER` over an entire table.
- Use `TREATAS` instead of `INTERSECT` for virtual relationships (better performance).

**DON'T:**
- Use implicit aggregations from numeric columns.
- Store all measures in a single dedicated table.
- Create untested measures.
- Use excessive `CALCULATE` nesting.
- Set `dataType` — measure data types are inferred from DAX expressions at runtime.
- Use `IFERROR` — causes performance degradation. Use `DIVIDE` for divide-by-zero or `IF` with explicit error checks.
- Create duplicate measures (two measures with the same DAX expression).
- Create measures that are just direct references to other measures (e.g., `[MeasureB] := [MeasureA]`).
- Use `1-(x/y)` or `1+(x/y)` syntax — instead compute the full expression with `DIVIDE` and `VAR`:
  ```
  -- Avoid: 1 - SUM('Sales'[Cost]) / SUM('Sales'[Revenue])
  -- Use:
  VAR _revenue = SUM('Sales'[Revenue])
  RETURN DIVIDE(_revenue - SUM('Sales'[Cost]), _revenue)
  ```
- Use `EVALUATEANDLOG` in production models (debug function only).

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

**Critical:** Every visible measure must have a `formatString` assigned.

## Relationships

**DO:**
- Create relationships before measures (measures may reference them)
- Default to single-directional: `CrossFilteringBehavior = "OneDirection"`
- Prefer integer keys over string keys (performance optimization)
- Ensure relationship columns on both sides have the same `dataType` (mismatched types cause errors and performance issues)
- Set `isKey = true` on the primary key column of dimension tables. Each dimension must have exactly ONE unique key column.
- Hide foreign key columns on the "many" side of relationships (`IsHidden = true`)
- Mark primary key columns on dimension tables (`IsKey = true`)

**DON'T:**
- Use Composite keys. They are NOT supported. 
- Do NOT create surrogate keys on Fact tables (memory waste)
- Use bi-directional cross-filtering unless strictly necessary (causes ambiguity and performance issues). If needed on many-to-many, always verify it is single-direction.
- Use many-to-many relationships unless required — they degrade performance. Keep bi-directional + many-to-many relationships below 30% of total relationships.
- Create inactive relationships unless they are activated via `USERELATIONSHIP` in at least one measure.
- Use `USERELATIONSHIP` against a table that also has Row-Level Security (causes errors).

## Date/Calendar Table

A Date/Calendar table is required for time-intelligence calculations such as Last Year or Year-To-Date.

**DO:**
- Use existing date table from data source (preferred).
- Create DAX calculated date table only if source table unavailable.
- Ensure contiguous date range (no gaps)
- Set the `dataCategory` property to "Time" for calendar tables.
- Ensure the common date attributes exist: Year, Quarter, Month, Day, Week (optional: Day of Week, Month Name)
- Configure the `sortByColumn` for text attributes such as "Month Name" (sort by month number to avoid alphabetical ordering).
- Disable auto-date tables if a proper date table exists (auto-date tables waste memory).

**DON'T:**
- Create a calendar table if there is a calendar table in the data source. Import that instead.
- Leave month name columns unsorted — they will sort alphabetically (April, August...) instead of chronologically.

## Hierarchies

**DO:**
- Create user hierarchies for common drill-down paths (e.g., Year > Quarter > Month > Day).
- Each hierarchy level must reference an existing column in the same table.
- Set meaningful level names that differ from the column names when appropriate.

**DON'T:**
- Create hierarchies with a single level (no drill-down value).
- Reference columns from other tables in hierarchy levels.

## Row-Level Security (RLS)

**DO:**
- Keep RLS filter expressions simple — push complex logic upstream to the data warehouse.
- Use single-direction relationships on security tables.
- Test RLS filters to ensure they return correct results.

**DON'T:**
- Use string manipulation functions (`RIGHT`, `LEFT`, `UPPER`, `LOWER`, `FIND`) in RLS expressions — offload to the data source.
- Use many-to-many relationships on tables with dynamic RLS (causes severe performance degradation).
- Combine `USERELATIONSHIP` with RLS on the same table (causes errors).

## Calculation Groups

**DO:**
- Use calculation groups for time intelligence variations (YTD, LY, etc.) to avoid measure explosion.
- Ensure calculation groups have at least one calculation item.
- Name calculation items clearly (e.g., `Current`, `YTD`, `PY`, `PY YTD`).

**DON'T:**
- Create empty calculation groups with no calculation items.
- Use calculation groups when simple measure variations are sufficient for a small number of measures.

## Performance Guidelines

**DO:**
- Prefer star schema over snowflake — avoid dimension-to-dimension relationships.
- Use `Int64` keys for relationships (faster than `String`).
- Minimize calculated columns — offload to the data source/warehouse when possible. Models with more than 5 calculated columns should be reviewed.
- If calculated columns use `RELATED()`, strongly consider moving that logic to the data source instead.
- Set `isAvailableInMdx = false` on hidden columns not used in sort-by, hierarchies, or variations.
- For DirectQuery models, be cautious with time-intelligence functions (known performance issues). Consider pre-calculating in the source.
- For DirectQuery with Power BI Premium, consider using aggregation tables to boost performance.
- Unpivot pivoted data (e.g., monthly columns like Jan, Feb, Mar) — import as rows, not columns.

**DON'T:**
- Use `Double` data type — use `Decimal` or `Int64`.
- Leave auto-date tables enabled when a proper date table exists.
- Create unnecessary bi-directional or many-to-many relationships.
- Include columns not needed for analysis — remove them at the source or hide them.

## Maintenance

- Remove hidden columns that are not referenced by any DAX expression, relationship, hierarchy, sort-by, or RLS.
- Remove hidden measures that are not referenced by any DAX expression.
- Remove inactive relationships not activated by any `USERELATIONSHIP` call.
- Remove unused data sources not referenced by any partition.
- Remove empty perspectives (perspectives with no tables).
- Fix referential integrity violations (orphan keys in fact tables not present in dimension tables).

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

