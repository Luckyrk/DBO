CREATE Procedure GetUserDetails_AdminScreen(@pcountrycode varchar(10),@pIdentityid uniqueidentifier)



as



select Id,UserName,[Password],(case when  ca.UserId is not null then  1 else  0 end) as HasRuleComposerAccess from IdentityUser i

left join CountryViewAccess ca on ca.UserId=i.UserName



where Id=@pIdentityid







select st.SystemRoleTypeId,st.[Description] as SystemRoleDescription from SystemUserRole sr



join IdentityUser i on i.Id=sr.IdentityUserId



join SystemRoleType st on st.SystemRoleTypeId=sr.SystemRoleTypeId



where i.Id=@pIdentityid











select SystemRoleTypeId,[Description] as SystemRoleDescription from SystemRoleType