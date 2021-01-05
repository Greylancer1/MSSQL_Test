--Create in each user database
--After this create sp_CHOMPforeachtable in the Master db by running RunProcOnAllTable.sql

If OBJECTPROPERTY(Object_id('dbo.CHOMP_SearchTableValues'), 'IsProcedure') = 1
  Drop Procedure dbo.CHOMP_SearchTableValues
go
Create Procedure dbo.CHOMP_SearchTableValues 
    @SearchTable   nvarchar(200)
  , @SearchDataType   nvarchar(100)
  , @SearchValue  nvarchar(255)
  , @Debug    int
As
Set Nocount On

--
-- Declare variables
--
Declare @ColumnName nvarchar(100)
  , @SqlString nvarchar(1000)
  , @TableName nvarchar(128)
  , @OwnerName nvarchar(128)

-- Get the table and owner names
Set @TableName = Parsename(@SearchTable,1)
Set @OwnerName = Parsename(@SearchTable,2)

--
-- Check parameters
--
If OBJECTPROPERTY(Object_id(@SearchTable), 'IsTable') = 0
Begin
  Print 'You must enter a valid search table string'
  Return(-1)  
End

If @OwnerName Is Null
Begin
  Print 'You must enter an owner name in the search table parameter'
  Return(-1)  
End

If Parsename(@SearchTable,3) Is Not Null
  If DB_Name() <> Parsename(@SearchTable,3)
    Begin
    Print 'You must use the current database name in the search table parameter'
    Return(-1)  
  End

If @SearchDataType not in ('char', 'int')
Begin
  Print 'You must enter a valid search data type'
  Return(-1)
End

If @SearchDataType like '%int%'
Begin
  If Isnumeric(@SearchValue) = 0
  Begin
    Print 'You must enter a valid numeric search data value'
    Return(-1)
  End
End


--
-- Create the results Table
--
If Object_id('#result', 'U') Is Not Null
  Drop Table #result
Create Table #result (ColumnName nvarchar(128), Result varchar(7500))

--
-- Initialize the loop
--
Set @ColumnName = (Select Min(column_name) 
  From INFORMATION_SCHEMA.COLUMNS 
  Where Table_name = @TableName
  And Table_Schema = Case When @OwnerName Is Not Null Then @OwnerName Else 'dbo' End
  And Data_type Like '%' + @SearchDataType + '%')
If @Debug = 1 Select @ColumnName As '@ColumnName'
While @ColumnName Is Not Null
Begin
  Set @SqlString = 'Select Distinct ' + '''' + @ColumnName + ''', '+ @ColumnName + ' From ' + @SearchTable + ' Where ' + @ColumnName + 
    Case   When @SearchDataType like '%char%' then ' like ''' + @SearchValue + ''''
      When @SearchDataType like '%int%'  then ' = ' + @SearchValue
    End
  If @Debug = 1 Print @SqlString
  Insert #result
    Exec(@SqlString)
  -- Get next column
  Set @ColumnName = (Select Min(column_name) 
    From INFORMATION_SCHEMA.COLUMNS 
    Where Table_name = @TableName
    And Table_Schema = Case When @OwnerName Is Not Null Then @OwnerName Else 'dbo' End
    And Data_type Like '%' + @SearchDataType + '%'
    And column_name > @ColumnName)
  If @Debug = 1 Select @ColumnName As '@ColumnName'
End
If Exists(Select Top 1 * From #result)
  Exec('Select ColumnName As ' + @TableName + ', Result From #Result')
Return



/********************************************************************************
Desc	From PASS to query for a string or int value in all columns of a table
Name	CRussell
Date	8/26/2002
********************************************************************************/