---
name: 'Calendar Instructions and Examples'
description: 'Guidelines for creating Power BI calendar objects'
uriTemplate: 'resource://calendar_instructions_and_examples'
---
# Calendar Column Groups Guide

This guide explains how to define calendar column groups in a Power BI date table so time intelligence works as expected and consistently across models.

## Concepts

- Calendar Column Groups. Use these when a primary column represents a standard time unit such as Year, Quarter, Month, Week, or Date. Time units (including "of year" variants) are defined by a fixed enumeration; use the exact casing from the **Allowed time units** list.
- Time-related groups. Use these for relative columns that are time-aware but are not a standard time unit (for example, RelativeMonth with values like "Current"/"Previous"). They can be used to slice/label time-aware analyses but do not themselves define a standard unit.
- Primary vs. associated columns. When a column maps to a specific unit, make it the primaryColumn for that unit. If column A is sorted by column B (Power BI SortByColumn), then B should be the primaryColumn and A should be an associatedColumn. Optionally add other 1-to-1 associatedColumns for alternate labels (e.g., a long and a short month name).

## Mapping guidance

- Calendar names must be unique across the entire model, not just within a single table. Even though a calendar belongs to a specific table, no two calendars in the model can share the same name.
- Each calendar definition must use columns from only its host table.
- Build hierarchies where each level subdivides exactly into the level above: Year → Quarter → Month → Date.
- For week-based (4-4-5, 4-5-4, 5-4-4, or ISO) calendars, the hierarchy is typically Year → Quarter → Period → Week → Date. Map the Period level to the `Month` time unit, because Period occupies the same hierarchical position between Week/Quarter and Year that Month does in a Gregorian calendar.
- When using ISO week numbers, always pair them with the corresponding ISO Year — not the Gregorian year. A date in early January may belong to the previous ISO year, and a date in late December may belong to the next ISO year. Mixing ISO weeks with Gregorian years produces incorrect results.
- Do not repeat a time unit within the same calendar.
- **Only one time-related group per calendar.** All time-related columns (relative offsets, flags like IsWeekend, FutureDate, etc.) must be combined into a **single** TimeRelated column group. The engine keys column groups by time unit; since all time-related columns share the implicit `Unknown` key, creating multiple separate TimeRelated groups will fail with: *"The CalendarColumnGroup with the key of 'TimeRelated' already exists."* Pass all such columns in one group's column list.
- A column must map to the same time unit (or as time-related) in every calendar that includes it.
- Do not use the same physical column more than once in the same calendar.
- Complete vs. Partial units:
  - Complete units uniquely identify a single period and must include the calendar context (e.g., include the year): Year, Quarter, Month, Week, Date.
    - Examples: 2024 (Year), Q3 2024 (Quarter), 2024-01 or "January 2024" (Month), 2024-W49 (Week), 2024-01-15 (Date).
  - Partial units are positions within a larger period and are not unique by themselves: QuarterOfYear (1–4), MonthOfYear (1–12 or names), WeekOfYear (1–52/53), DayOfYear (1–365/366). Variants exist for Quarter/Month (e.g., MonthOfQuarter).
    - Use these primarily for labels, slicers, or seasonality—not as keys or for hierarchical rollups.
  - Mapping examples:
    - "December 2024" → Month (complete, includes year). "December" → MonthOfYear (not unique across years).
    - "Q3 2023" → Quarter. "Q3" → QuarterOfYear.
    - "2024-W49" or "Week 49 of 2024" → Week. "Week 49" → WeekOfYear.
    - "15th day of month" → DayOfMonth. "15th day of the year" → DayOfYear.
  - Rules of thumb:
    - For standard hierarchies (Year → Quarter → Month → Date), use complete units at every level.
    - You may associate a partial label with a complete primary (e.g., Month primary: Year Month; associated label: MonthOfYear name) if it is 1-to-1 with the primary.
    - Do not map MonthOfYear to Month, WeekOfYear to Week, or QuarterOfYear to Quarter—these are different concepts.
    - For weeks, prefer ISO Year-Week for complete Week labels. If your organization uses a non-ISO week system, still include the year context and use your defined week-numbering convention.

## Allowed time units

Time unit values are **case-sensitive enum names**, not natural-language words. Common mistakes:
- Do **not** pluralize: use `Year`, not `Years`; `Quarter`, not `Quarters`; `Month`, not `Months`.
- The daily unit is `Date`, not `Day` or `Days`.
- Compound units use exact PascalCase: `MonthOfYear`, not `MonthOfYear` variants like `monthofyear` or `Month_Of_Year`.

The API validates the first column group and rejects the entire request on the first invalid value.

```yaml
timeUnits:
  - id: Unknown
    example: "IsWeekend"
    note: "Used for all time-related columns (season-type, period-type, flags, etc.)."
  - id: Year
    example: 2022
  - id: Quarter
    example: "Q3 2022"
  - id: QuarterOfYear
    example: 4        # 4th quarter of the year
  - id: Month
    example: "January 2022"
  - id: MonthOfYear
    example: "January"
  - id: MonthOfQuarter
    example: 2        # 2nd month of the quarter
  - id: Week
    example: "2022-W49"   # ISO Year-Week or unique year+week label
  - id: WeekOfYear
    example: 49
  - id: WeekOfQuarter
    example: 11
  - id: WeekOfMonth
    example: 3
  - id: Date
    example: "2022-01-01"
  - id: DayOfYear
    example: 241
  - id: DayOfQuarter
    example: 71
  - id: DayOfMonth
    example: 23
  - id: DayOfWeek
    example: 4         # e.g., Thursday if 1=Monday
```

## Example

```yaml
Tables:
  - Name: DimDate
    Columns:
      - Name: Date
        Type: Date
      - Name: Year
        Type: Integer
      - Name: Quarter
        Type: Text
        SortByColumnName: Year Quarter Number
      - Name: Year Quarter
        Type: Text
        SortByColumnName: Year Quarter Number
      - Name: Year Quarter Number
        Type: Integer
      - Name: Month
        Type: Text
        SortByColumnName: Month Number
      - Name: Month Short
        Type: Text
        SortByColumnName: Month Number
      - Name: Month Number
        Type: Integer
      - Name: Year Month
        Type: Text
        SortByColumnName: Year Month Number
      - Name: Year Month Short
        Type: Text
        SortByColumnName: Year Month Number
      - Name: Year Month Number
        Type: Integer
      - Name: Week of Year
        Type: Integer
      - Name: ISO Year-Week
        Type: Text
        SortByColumnName: ISO Year-Week Number
      - Name: ISO Year-Week Number
        Type: Integer
      - Name: Fiscal Year Number
        Type: Integer
      - Name: Fiscal Year Name
        Type: Text
        SortByColumnName: Fiscal Year Number
      - Name: Fiscal Year Month
        Type: Text
        SortByColumnName: Fiscal Year Month Number
      - Name: Fiscal Year Month Number
        Type: Integer
      - Name: Fiscal Month Number of Year
        Type: Integer
      - Name: Fiscal Month Name
        Type: Text
        SortByColumnName: Fiscal Month Number of Year
      - Name: RelativeMonth  # Period-type: represents relative states
        Type: Text
      - Name: Season         # Season-type: represents cyclical concepts
        Type: Text
    Calendars:
      - name: Gregorian Calendar
        calendarColumnGroups:
          - timeUnit: Year
            primaryColumn: Year
          - timeUnit: Quarter
            primaryColumn: Year Quarter Number
            associatedColumns:
              - Year Quarter
          - timeUnit: Month
            primaryColumn: Year Month Number
            associatedColumns:
              - Year Month
              - Year Month Short
          - timeUnit: Week
            primaryColumn: ISO Year-Week Number
            associatedColumns:
              - ISO Year-Week
          - timeUnit: WeekOfYear
            primaryColumn: Week of Year
          - timeUnit: Date
            primaryColumn: Date
      - name: Fiscal Calendar
        calendarColumnGroups:
          - timeUnit: Year
            primaryColumn: Fiscal Year Number
            associatedColumns:
              - Fiscal Year Name
          - timeUnit: Month
            primaryColumn: Fiscal Year Month Number
            associatedColumns:
              - Fiscal Year Month
          - timeUnit: MonthOfYear
            primaryColumn: Fiscal Month Number of Year
            associatedColumns:
              - Fiscal Month Name
        timeRelatedGroups:
          - column: RelativeMonth
          - column: Season
```

**API note:** The `timeRelatedGroups` entries above represent individual columns within **one** group, not separate groups. When calling the calendar API, combine them into a single TimeRelated column group: `{"groupType": "TimeRelated", "timeRelatedGroup": {"columns": ["RelativeMonth", "Season"]}}`.

## Week-based (4-4-5 / ISO) calendar example

In a week-based calendar, weeks are a proper hierarchical level. Periods replace months and contain a whole number of weeks (e.g., 4, 4, and 5 weeks per quarter in a 4-4-5 pattern). As noted in Mapping guidance, map Period to the `Month` time unit and use the ISO year — not the Gregorian year — as the year column.

```yaml
Tables:
  - Name: ISO Date
    Columns:
      - Name: Date
        Type: Date
      - Name: ISO Year
        Type: Integer
      - Name: Year-Period
        Type: Integer
        # e.g., 202403 = period 3 of ISO year 2024
      - Name: Year-Week
        Type: Integer
        # e.g., 202449 = week 49 of ISO year 2024
      - Name: Period
        Type: Integer
        # Period number within the year (1-12)
      - Name: ISO Week
        Type: Integer
        # ISO week number (1-53)
      - Name: Week in Period
        Type: Integer
        # Week position within its period (1-4 or 1-5)
      - Name: Day of Week
        Type: Integer
        # 1=Monday through 7=Sunday
    Calendars:
      - name: ISOCalendar445
        calendarColumnGroups:
          - timeUnit: Year
            primaryColumn: ISO Year
          - timeUnit: Month
            # Period maps to Month because it occupies the same
            # hierarchical position between Week and Year
            primaryColumn: Year-Period
          - timeUnit: MonthOfYear
            primaryColumn: Period
          - timeUnit: Week
            primaryColumn: Year-Week
          - timeUnit: WeekOfYear
            primaryColumn: ISO Week
          - timeUnit: Date
            primaryColumn: Date
        timeRelatedGroups:
          - column: Week in Period
          - column: Day of Week
```

**Notes on week-based calendars and time intelligence:**
- With a custom calendar defined this way, standard DAX time intelligence functions (DATESYTD, DATESMTD, DATESWTD, SAMEPERIODLASTYEAR, DATEADD) automatically adapt to the week-based hierarchy.
- DATESMTD returns period-to-date results (since Period is mapped to Month).
- DATESWTD returns week-to-date results.
- SAMEPERIODLASTYEAR shifts to the same week number and day-of-week in the previous ISO year, which ensures that comparisons always cover the same number of days.
- DATEADD supports Extension (Precise or Extending) and Truncation (Anchored or Blanks) parameters to handle shifts between periods of different lengths (e.g., 4-week vs. 5-week periods).
