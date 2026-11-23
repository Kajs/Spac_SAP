@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stock allocations'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZR_SPAC103_STALLOC
  as select from zspac103_stalloc

  association to parent ZR_SPAC103_CITEM as _Item
    on  $projection.CartUUID = _Item.CartUUID
    and $projection.ProductId = _Item.ProductId
    
  association to ZR_SPAC103_CART_DD_RWE as _Cart
    on $projection.CartUUID = _Cart.CartUUID

{
  key cart_uuid as CartUUID,
  key product_id as ProductId,
  key warehouse_id as WarehouseId,

      allocated_quantity as AllocatedQuantity,

      _Item,
      _Cart
}
