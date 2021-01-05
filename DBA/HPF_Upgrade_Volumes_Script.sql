SET nocount ON
print 'Number of Images inserted into the cabinet Table in the last 30 days'
select count(*) from cabinet..cabinet (nolock)where IMAGEDATE > DATEADD(day, -30, getdate()) AND Deleted = 'N' 
print ''

print 'Number of Scanned Images inserted into the cabinet Table in the last 30 days'
select count(*) from cabinet..cabinet (nolock)where IMAGEDATE > DATEADD(day, -30, getdate()) AND Deleted = 'N' AND Filename = 'PAG'
print ''

print 'Number of COLD Images inserted into the cabinet Table in the last 30 days'
select count(*) from cabinet..cabinet (nolock)where IMAGEDATE > DATEADD(day, -30, getdate()) AND Deleted = 'N' AND Filename = 'CLD'
print ''

print 'Number of Images inserted into the cabinet Table in the last Year'
select count(*) from cabinet..cabinet (nolock) where IMAGEDATE > DATEADD(day, -365, getdate()) AND Deleted = 'N' 
print ''

print 'Number of Scanned Images inserted into the cabinet Table in the last Year'
select count(*) from cabinet..cabinet (nolock) where IMAGEDATE > DATEADD(day, -365, getdate()) AND Deleted = 'N' AND Filename = 'PAG'
print ''

print 'Number of COLD Images inserted into the cabinet Table in the last Year'
select count(*) from cabinet..cabinet (nolock) where IMAGEDATE > DATEADD(day, -365, getdate()) AND Deleted = 'N' AND Filename = 'CLD'
print ''

print 'Total Number of Images inserted into the cabinet'
select count(*) from cabinet..cabinet (nolock) where  Deleted = 'N' 