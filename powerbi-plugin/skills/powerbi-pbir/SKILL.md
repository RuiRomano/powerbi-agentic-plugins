---
name: powerbi-pbir
description: Guide to develop Power BI Reports PBIR format. Use this skill for any development operation against a Power BI Report PBIR file format. Use this skill whenever asked to make a change to a Power BI report using code.
---

# Power BI Report (PBIR) Skill

## Core principles

- Schema‑aware: validate JSON against the declared $schema; call out violations and propose fixes.
- Understand the [PBIP file structure](../powerbi-semantic-model/references/pbip.md).

## PBIR file format

Example of a report folder using `PBIR` format:

```text
Report/
├── StaticResources/ # stores report resources such as images, custom themes,... 
│   ├── RegisteredResources/
│   │   ├── logo.jpg
│   │   ├── CustomTheme4437032645752863.json
├── definition/ # stores the entire report definition: pages, visuals, bookmarks
│   ├── bookmarks/
│   │   ├── Bookmark7c19b7211ada7de10c30.bookmark.json
│   │   ├── bookmarks.json
│   ├── pages/
│   │   ├── 61481e08c8c340011ce0/
│   │   │   ├── visuals/
│   │   │   │   ├── 3852e5607b224b8ebd1a/
│   │   │   │   │   ├── visual.json
│   │   │   │   │   ├── mobile.json
│   │   │   │   ├── 7df3763f63115a096029/
│   │   │   │   │   ├── visual.json
│   │   │   ├── page.json
│   │   ├── pages.json
│   ├── version.json
│   ├── report.json
├── semanticModelDiagramLayout.json # Copy of the semantic model diagram layout the report is connected to.
└── definition.pbir # Overall definition of the report and core settings. Also holds the reference to the semantic model of the report, it's possible to rebind the report to a different semantic model by updating this file.
```

## Name property

All report objects have a `name` property. For example see the `visual.json`:

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.1.0/schema.json",
  "name": "5868707ac858bcbe007a",
  "position": {
    "x": 32.118081180811807,
    "y": 216.32472324723247,
    "z": 4000,
    "height": 492.16236162361622,
    "width": 366.52398523985238,
    "tabOrder": 2000
  },
  "visual": {
    "visualType": "barChart",
    "drillFilterOtherVisuals": true
  }
}
```

By default PBIR folder uses the internal `name` property of pages, visuals and bookmarks in the files or folders. For example consider the following path of a visual:

  `Sales.Report\definition\pages\89a9619c7025093ade1c\visuals\5acb1caf298449a8acb4\visual.json`

  `89a9619c7025093ade1c` is the name of the page and `5acb1caf298449a8acb4` the name of the visual.

## Task: Create new report on top of semantic model

- Create or reuse an existing report PBIP folder
- Copy the `assets/templateReport/report/definition` and `assets/templateReport/report/StaticResources` to the `*.Report` folder 
- Load [templatereport-kb.md](assets/templateReport/template-report-kb.md) to understand how to manipulate the PBIR definition and adapt it to the semantic model

## Task: Align Power BI Report visuals

- Make sure you have access to the code definition of the report and its using PBIR format. Confirm there is a `definition/` folder.
- For each page:
  - Inspect all visual.json files and look for the `position` property
  - Build a wireframe to understand each visual X and Y position as well as it's height and width
  - Infer the current page layout into rows and columns and make sure that the visuals are aligned consistently:
    - Horizonal and Vertical distribution is the same
    - Ensure that the entire row is filled, for example if there is only one visual change its width and height to fill the row
    - When possible make sure that for each row all visuals have the same size (height and width)

## Task: Rename folders to improve readability

- The internal name by default is used in the folder and file names
- You can change the folder and file name for the following objects: page, visual, bookmark

## Task: Export a report from Workspace

- Create folder structure following the [pbip](../powerbi-semantic-model/references/pbip.md) guidelines.
- Use Fabric CLI to export the report code definition into the `definition/` local folder
  
## Task: Import/Deploy a report to a Workspace

- Use the Fabric CLI, note that you can easily deploy with a new name.
- **CRITICAL:** When deploying a report to a workspace the `definition.pbir` must use a `byConnection` configuration and target a workspace semantic model. Consider the following example:

    ```json
    {  
      "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json",
      "version": "4.0",
      "datasetReference": {
        "byConnection": {      
          "connectionString": "semanticmodelid=[SemanticModelId]"
        }
      }
    }
    ```

## Task: Rebind Power BI Report to a different semantic model

If the target semantic model is in a local folder, change the `definition.pbir` and configure a `byPath` property using a relative reference to the model. Example:

  ```json
  {
    "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json",
    "version": "4.0",
    "datasetReference": {
      "byPath": {
        "path": "../Sales.SemanticModel"
      }
    }
  }
  ```

If the target semantic model is in a Fabric workspace:
  - Find the semantic model ID
  - Change the `definition.pbir` and configure a `byConnection` property targeting the semantic model ID

      ```json
      {  
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json",
        "version": "4.0",
        "datasetReference": {
          "byConnection": {      
            "connectionString": "semanticmodelid=[SemanticModelId]"
          }
        }
      }
      ```

## Task: Analyze report against best practices

- Run the Best Practice Analysis by executing the script `..\powerbi-semantic-model\scripts\bpa.ps1 -src [path to the report]`
- Report findings with severity levels (Critical, High, Medium, Info)
  
## References

**External references** (request markdown when possible):

- [PBIR docs](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report?tabs=v2%2Cdesktop#pbir-format)
