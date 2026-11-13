@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view entity for Warehouse'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_SPAC103_WAREHOU_DD_RWE
  as select from zspac103_warehou
{
  key warehouse_id as WarehouseId,

      warehouse_address as WarehouseAddress,
      warehouse_zipcode as WarehouseZipcode,
      warehouse_city as WarehouseCity,
      warehouse_name as WarehouseName,

      @Semantics.user.createdBy: true
      local_created_by as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt
}
