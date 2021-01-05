SELECT DISTINCT [Order_Type]
      ,[Instance]
      ,[DB]
      ,[text]
  FROM [DBA].[dbo].[ExpSQLQueriesMon]
  WHERE Instance LIKE 'CSRSQL1B\CSRSQL1B' AND Order_Type = 'Most Physical Reads'