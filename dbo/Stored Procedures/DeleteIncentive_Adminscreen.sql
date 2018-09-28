Create procedure DeleteIncentive_Adminscreen(
@pGuid uniqueidentifier
)
As
Begin
Declare @TransactionInfo_Id uniqueidentifier
Declare @TransactionType nvarchar(30)
Declare @PackageGuid uniqueidentifier
Set    @TransactionInfo_Id=(select top 1 TransactionInfo_Id from IncentiveAccountTransaction where IncentiveAccountTransactionId = @pGuid)
Set   @TransactionType =(select top 1 Type from IncentiveAccountTransaction where IncentiveAccountTransactionId = @pGuid)
Set     @PackageGuid=(select top 1 GUIDReference from Package where Debit_Id = @pGuid  )

If  (@TransactionType ='Debit')
Begin

Delete from   StateDefinitionHistory where Package_Id = @PackageGuid
Delete from   Package where Debit_Id=@pGuid
Delete from   IncentiveAccountTransaction where TransactionInfo_Id=@TransactionInfo_Id
Delete from   IncentiveAccountTransactionInfo where IncentiveAccountTransactionInfoId=@TransactionInfo_Id

End

Else
Begin

Delete from    IncentiveAccountTransaction where TransactionInfo_Id=@TransactionInfo_Id
Delete  from IncentiveAccountTransactionInfo where IncentiveAccountTransactionInfoId=@TransactionInfo_Id

End


End