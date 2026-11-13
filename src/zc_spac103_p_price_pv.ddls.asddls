@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for _P_PRICE'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZC_SPAC103_P_PRICE_PV as projection on ZR_SPAC103_P_PRICE
{
  key ProductId,
  key ProductCurrencyCode,
  @Semantics.amount.currencyCode: 'ProductCurrencyCode'
  ProductPrice,
  /* Associations */
  _Product : redirected to parent ZC_SPAC103_PRODUCT_DD_PV
}
