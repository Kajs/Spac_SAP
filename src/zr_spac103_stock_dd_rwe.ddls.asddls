@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stock entries'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_SPAC103_STOCK_DD_RWE
  as select from zspac103_stock

  association [0..1] to zspac103_product as _Product
    on $projection.ProductId = _Product.product_id

  association [0..1] to zspac103_warehou as _Warehouse
    on $projection.WarehouseId = _Warehouse.warehouse_id
    

{
  key warehouse_id as WarehouseId,
  key product_id   as ProductId,
      amount       as Amount,

  _Product.product_name        as ProductName,
  _Product.product_description as ProductDescription,

  _Warehouse.warehouse_name    as WarehouseName,
  _Warehouse.warehouse_address as WarehouseAddress,
  _Warehouse.warehouse_zipcode as WarehouseZipcode,
  _Warehouse.warehouse_city    as WarehouseCity,

  _Product,
  _Warehouse
}
