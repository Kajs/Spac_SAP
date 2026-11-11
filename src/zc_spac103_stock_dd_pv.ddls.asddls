@EndUserText.label: 'Projection view for stock'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_SPAC103_STOCK_DD_PV
  provider contract transactional_query
  as projection on ZR_SPAC103_STOCK_DD_RWE
{
  key WarehouseId,
  key ProductId,
      Amount,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      ProductName,
      ProductDescription,

      WarehouseName,
      WarehouseAddress,
      WarehouseZipcode,
      WarehouseCity,

      _Product,
      _Warehouse
}

