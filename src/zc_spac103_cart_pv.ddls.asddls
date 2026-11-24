@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shopping cart'
@Metadata.allowExtensions: true

define root view entity ZC_SPAC103_CART_PV
  provider contract transactional_query
  as projection on ZR_SPAC103_CART_DD_RWE
{
  key CartUUID,

      CurrencyCode,
      CartTotalAmount,
      CartStatus,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      _Items : redirected to composition child ZC_SPAC103_CITEM_PV
}
