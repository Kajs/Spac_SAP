@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shopping cart items'
@Metadata.allowExtensions: true

define view entity ZC_SPAC103_CITEM_PV
  as projection on ZR_SPAC103_CITEM
{
  key CartUUID,
  key ProductId,

      ProductName,
      Quantity,
      CurrencyCode,
      UnitPrice,
      CartUnitTotal,

      _Cart : redirected to parent ZC_SPAC103_CART_PV
}
