DECLARE 
    @FileContent VARBINARY(MAX),
    @FileName VARCHAR(MAX),
    @ObjectToken INT,
    @FileID BIGINT

DECLARE cFiles CURSOR FAST_FORWARD FOR
SELECT Id, DocumentName, DocumentData from EmployeeDocuments
OPEN cFiles

FETCH NEXT FROM cFiles INTO @FileID, @FileName, @FileContent

WHILE @@FETCH_STATUS = 0 BEGIN

    -- CHOOSE 1 of these SET statements:

    --if FileName is unique, then just remove special characters
    SET @FileName = 'D:\Export\Docs\' + CAST(@FileID AS varchar) + '_' + @FileName
    -- if FileName without path information is unique
    --SET @FileName = SUBSTRING(@FileName,
      --  len(@FileName)+2-CHARINDEX('\',REVERSE(@FileName)),len(@FileName))
    -- if you just take ID + extensions
    --SET @FileName = 'D:\Export\Docs\' + CAST(@FileID AS varchar) + 
       -- SUBSTRING(@ap_description,len(@ap_description)+1
         --   -CHARINDEX('.',REVERSE(@ap_description)),len(@ap_description))

    EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
    EXEC sp_OASetProperty @ObjectToken, 'Type', 1
    EXEC sp_OAMethod @ObjectToken, 'Open'
    EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @FileContent
    EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @FileName, 2
    EXEC sp_OAMethod @ObjectToken, 'Close'
    EXEC sp_OADestroy @ObjectToken

    FETCH NEXT FROM cFiles INTO @FileID, @FileName, @FileContent
END

CLOSE cFiles