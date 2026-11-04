@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Stock entries'

@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_SPAC103_STOCK_DD_RWE
  as select from zspac103_stock
{
  key warehouse_id as WarehouseId,
  key product_id   as ProductId,
      amount       as Amount
}
