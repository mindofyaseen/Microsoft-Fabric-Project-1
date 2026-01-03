let
  Source = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navigation 1" = Source{[workspaceId = "a329a3ee-5092-4875-9843-9b802c9292e2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "923a8545-fbf3-40ef-9308-85a790e6baba"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "Transformation of DataFlowGen2"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "Fact_Sales.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 5", [Delimiter = ",", Columns = 8, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"OrderDate", type date}, {"StockDate", type date}, {"OrderNumber", type text}, {"ProductKey", Int64.Type}, {"CustomerKey", Int64.Type}, {"TerritoryKey", Int64.Type}, {"OrderLineItem", Int64.Type}, {"OrderQuantity", Int64.Type}}),
  #"Grouped rows" = Table.Group(#"Changed column type", {"ProductKey"}, {{"Total Quantity", each List.Sum([OrderQuantity]), type nullable number}}),
  #"Renamed columns" = Table.RenameColumns(#"Grouped rows", {{"Total Quantity", "Total_Quantity"}})
in
  #"Renamed columns"