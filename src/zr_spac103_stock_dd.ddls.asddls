@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total stock per warehouse'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZR_SPAC103_STOCK_DD
  as select from zspac103_stock
{
  key warehouse_id as Warehouse_id,

      sum( amount ) as TotalStock
}
group by warehouse_id
