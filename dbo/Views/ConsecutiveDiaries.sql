CREATE View [dbo].[ConsecutiveDiaries]
as
select de.BusinessId, p.PanelCode, de.ReceivedDate, de.NumberOfDaysEarly, de.NumberOfDaysLate, c.CountryISO2A---, count(*) [count]
from diaryentry de
join Panel P on p.guidreference=de.panelid
join country  c on c.countryid=p.Country_id