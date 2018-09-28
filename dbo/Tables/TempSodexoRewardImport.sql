CREATE TABLE [dbo].[TempSodexoRewardImport] (
JobId UNIQUEIdentifier,
[Rownumber] [int] identity(1,1),
[Hogar] NVARCHAR(MAX),
[ID línea de Pedidos] NVARCHAR(MAX),
[Referencia del pedido] NVARCHAR(MAX),
[Proveedor] NVARCHAR(MAX),
[Producto] NVARCHAR(MAX),
[SKU] NVARCHAR(MAX),
[Cantidad] NVARCHAR(MAX),
[PUNTOS] NVARCHAR(MAX),
[Precio por unidad] NVARCHAR(MAX),
[Total Valor] NVARCHAR(MAX),
[Nombre Panelista] NVARCHAR(MAX),
[Dirección] NVARCHAR(MAX),
[Teléfono] NVARCHAR(MAX),
[Comentario] NVARCHAR(MAX),
[Correo electrónico] NVARCHAR(MAX),
[Observación] NVARCHAR(MAX)
)
GO