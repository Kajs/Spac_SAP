@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Warehouse'
@Metadata.allowExtensions: true

define root view entity ZC_SPAC103_WAREHOU_DD_PV
  provider contract transactional_query
  as projection on ZR_SPAC103_WAREHOU_DD_RWE
{
  key WarehouseId,
      WarehouseName,
      WarehouseAddress,
      WarehouseZipcode,
      WarehouseCity,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt
}
