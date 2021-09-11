select
    AName = case 
        when AName in (select AName from Hierarchy group by AName having COUNT(*) > 1)
        then AName + char(96+row_number() over (partition by AName order by AName))
        else AName 
    end,
	*
from 
    Hierarchy
WHERE AName = 'East' 