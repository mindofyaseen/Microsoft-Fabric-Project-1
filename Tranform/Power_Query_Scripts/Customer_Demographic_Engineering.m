let
  Source = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navigation 1" = Source{[workspaceId = "a329a3ee-5092-4875-9843-9b802c9292e2"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[lakehouseId = "923a8545-fbf3-40ef-9308-85a790e6baba"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 4" = #"Navigation 3"{[Name = "Dumped Raw Data"]}[Content],
  #"Navigation 5" = #"Navigation 4"{[Name = "AdventureWorks_Customers.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 5", [Delimiter = ",", Columns = 13, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"CustomerKey", Int64.Type}, {"Prefix", type text}, {"FirstName", type text}, {"LastName", type text}, {"BirthDate", type date}, {"MaritalStatus", type text}, {"Gender", type text}, {"EmailAddress", type text}, {"AnnualIncome", Currency.Type}, {"TotalChildren", Int64.Type}, {"EducationLevel", type text}, {"Occupation", type text}, {"HomeOwner", type text}}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Changed column type", "Full Name", each [FirstName] & " " & [LastName]), {{"Full Name", type text}}),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Added custom", "Age", each Date.Year(DateTime.LocalNow()) - Date.Year([BirthDate])), {{"Age", Int64.Type}}),
  #"Inserted conditional column" = Table.AddColumn(#"Added custom 1", "Income Bracket", each if [AnnualIncome] >= 100000 then "Premium" else if [AnnualIncome] >= 50000 then "Mid-Range" else "Budget"),
  #"Changed column type with locale" = Table.TransformColumnTypes(#"Inserted conditional column", {{"Income Bracket", type text}}),
  #"Renamed columns" = Table.RenameColumns(#"Changed column type with locale", {{"Income Bracket", "Income_Bracket"}, {"Full Name", "Full_Name"}})
in
  #"Renamed columns"