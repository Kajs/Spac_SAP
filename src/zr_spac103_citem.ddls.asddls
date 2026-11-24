@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shopping cart items'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZR_SPAC103_CITEM
  as select from zspac103_citem
  
  association to parent ZR_SPAC103_CART_DD_RWE as _Cart
  on $projection.CartUUID = _Cart.CartUUID
  
  composition [0..*] of ZR_SPAC103_STALLOC as _Allocations
{
  key cart_uuid as CartUUID,
  key product_id as ProductId,

      product_name as ProductName,
      quantity as Quantity,
      currency_code as CurrencyCode,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      unit_price as UnitPrice,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      cart_unit_total as CartUnitTotal,
      
      _Cart,
      _Allocations
}
