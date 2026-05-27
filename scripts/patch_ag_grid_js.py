# -*- coding: utf-8 -*-
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "web" / "js"
SNIPPET = "if (window.AgGridPage) { window.AgGridPage.onGridReady(params, container); }\n                "

PATCHES = [
    ("audit/ag-grid.js", "onGridReady: function(params) {\n                gridApi = params.api;", SNIPPET + "gridApi = params.api;"),
    ("software/ag-grid.js", "onGridReady: function(params) {\n                gridApi = params.api;", SNIPPET + "gridApi = params.api;"),
    ("references/ag-grid.js", "onGridReady: function(params) {\n                gridApi = params.api;", SNIPPET + "gridApi = params.api;"),
    ("users/ag-grid.js", "onGridReady: function(params) {\n                gridApi = params.api;", SNIPPET + "gridApi = params.api;"),
    ("user-equipment-cards/ag-grid.js", "onGridReady: function(params) {\n                gridApi = params.api;", SNIPPET + "gridApi = params.api;"),
    ("tasks/statistics-ag-grid.js", "onGridReady: function(params) {\n                fetch(dataUrl)", SNIPPET + "fetch(dataUrl)"),
]

def patch_tasks():
    p = ROOT / "tasks/ag-grid.js"
    t = p.read_text(encoding="utf-8")
    old = "function onGridReady(params) {\n    loadGridData();"
    new = (
        "function onGridReady(params) {\n"
        "    var tasksContainer = document.getElementById('agGridTasksContainer');\n"
        "    if (window.AgGridPage) { window.AgGridPage.onGridReady(params, tasksContainer); }\n"
        "    loadGridData();"
    )
    if old in t and "AgGridPage" not in t.split("function onGridReady")[1][:200]:
        t = t.replace(old, new, 1)
        p.write_text(t, encoding="utf-8")
        print("tasks")

def patch_arm():
    p = ROOT / "arm/ag-grid.js"
    t = p.read_text(encoding="utf-8")
    old = "onGridReady: function(params) {\n                gridApi = params.api;"
    new = (
        "onGridReady: function(params) {\n"
        "                if (window.AgGridPage) { window.AgGridPage.onGridReady(params, container); }\n"
        "                gridApi = params.api;"
    )
    if old in t and "AgGridPage.onGridReady" not in t:
        t = t.replace(old, new, 1)
        p.write_text(t, encoding="utf-8")
        print("arm")

def main():
    for rel, old, new in PATCHES:
        p = ROOT / rel
        t = p.read_text(encoding="utf-8")
        if old in t and "AgGridPage" not in t[t.find(old) : t.find(old) + 120]:
            t = t.replace(old, new, 1)
            p.write_text(t, encoding="utf-8")
            print(rel)
    patch_tasks()
    patch_arm()

if __name__ == "__main__":
    main()
