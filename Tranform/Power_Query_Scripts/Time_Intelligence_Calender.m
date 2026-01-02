let
  Source = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navigation 1" = Source{[workspaceId = "a329a3ee-5092-4875-9843-9b802c9292e2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "923a8545-fbf3-40ef-9308-85a790e6baba"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "Dumped Raw Data"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "AdventureWorks_Calendar.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 5", [Delimiter = ",", Columns = 1, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"Date", type date}}),
  #"Inserted year" = Table.AddColumn(#"Changed column type", "Year", each Date.Year([Date]), type nullable number),
  #"Inserted month" = Table.AddColumn(#"Inserted year", "Month", each Date.Month([Date]), type nullable number),
  #"Inserted quarter" = Table.AddColumn(#"Inserted month", "Quarter", each Date.QuarterOfYear([Date]), type nullable number),
  #"Inserted day name" = Table.AddColumn(#"Inserted quarter", "Day name", each Date.DayOfWeekName([Date]), type nullable text),
  #"Inserted conditional column" = Table.AddColumn(#"Inserted day name", "Weekend Flag", each if [Day name] = "Saturday" then "Weekend" else if [Day name] = "Sunday" then "Weekend" else "Weekday"),
  #"Changed column type with locale" = Table.TransformColumnTypes(#"Inserted conditional column", {{"Weekend Flag", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type with locale", {{"Weekend Flag", "Weekend_Flag"}, {"Day name", "Day_name"}})
in
  #"Renamed columns"