--Convert into SP Pass in Username grab UserID from users table and pass it to where clause to grab rights
--Post Username right in Select 
DECLARE @Username varchar(50)
DECLARE @UserID int
SET @Username = 'Bar'
SELECT @Username
SET @UserID = (SELECT UserID FROM Users WHERE Username = @Username) 
SELECT @UserID

select @Username AS Username, child.*, child.[parentage].ToString() AS ParentageTxt
from Hierarchy as parent
inner join Hierarchy as child
   on child.Parentage.IsDescendantOf(
       parent.Parentage
   ) = 1
where Parent.[parentage].ToString() in (SELECT ParentagePerm From dbo.Perms WHERE UserID = @UserID)