USE [medgateClean_v60]
GO

DECLARE @TableName nvarchar (128), @columns varchar(max), @sql varchar(max), @data_file varchar(100), @file_name varchar(100)

  SELECT @file_name='D:\Export\'
	SET @TABLENAME ='CASEACTIVITY_AUDIT'

	BEGIN
		select 
				@columns=coalesce(@columns+',','')+column_name+' as '+column_name 
		from 
				information_schema.columns
		where 
				table_name=@Tablename

		set @columns=''''''+replace(replace(@columns,' as ',''''' as '),',',',''''')
		
--select @data_file=substring(@file_name,1,len(@file_name)-charindex('\',reverse(@file_name)))+'\data_file.csv'

		--Generate column names in the passed EXCEL file
		set @sql='exec master..xp_cmdshell ''bcp " select * from (select '+@columns+') as t" queryout "D:\Export\Columns.csv" -c -t, -T'''
--set @sql='exec master..xp_cmdshell ''bcp " select * from (select '+@columns+') as t" queryout "'+@file_name+@TableName+'.csv" -c -t, -T'''
		exec(@sql)

		--Generate data in the dummy file
		set @sql='exec master..xp_cmdshell ''bcp "select * from medgateClean_v60..'+@tablename+'" queryout "D:\Export\data_file.csv" -c -t"\",\"" -r"\"\n\"" -T'''
--\",\" /r\"\r\n\"'''
		exec(@sql)

		--Copy dummy file to passed EXCEL file
		set @sql= 'exec master..xp_cmdshell ''type D:\Export\Columns.csv >> '+@file_name+@TableName+'.csv'''
		exec(@sql)
		set @sql= 'exec master..xp_cmdshell ''type D:\Export\data_file.csv >> '+@file_name+@TableName+'.csv'''
		exec(@sql)

		--Delete dummy file 
		set @sql= 'exec master..xp_cmdshell ''del D:\Export\Columns.csv'''
		exec(@sql)
		set @sql= 'exec master..xp_cmdshell ''del D:\Export\data_file.csv'''
		exec(@sql)
		SET @columns=NULL
	END
