@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shopping carts'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_SPAC103_CART_DD_RWE
  as select from zspac103_cart
  
  composition [0..*] of ZR_SPAC103_CITEM as _Items
{
  key cart_uuid as CartUUID,

      currency_code as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      cart_total_amount as CartTotalAmount,
      cart_status as CartStatus,

      @Semantics.user.createdBy: true
      local_created_by as LocalCreatedBy,

      @Semantics.systemDateTime.createdAt: true
      local_created_at as LocalCreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      
      _Items
}
