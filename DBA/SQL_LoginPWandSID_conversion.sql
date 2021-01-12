Begin
    Set @PasswordHashString = '0x' +
        Cast('' As XML).value('xs:hexBinary(sql:variable("@PasswordHash"))', 'nvarchar(300)');
 
    Set @SQL = @SQL + ' With Password = ' + @PasswordHashString + ' HASHED, ';
 
    Set @SIDString = '0x' +
        Cast('' As XML).value('xs:hexBinary(sql:variable("@SID"))', 'nvarchar(100)');
    Set @SQL = @SQL + 'SID = ' + @SIDString + ';';
End