@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product price child cds view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_SPAC103_P_PRICE as select from zspac103_p_price

association to parent ZR_SPAC103_PRODUCT_DD_RWE as _Product
  on $projection.ProductId = _Product.ProductId 

{
  key product_id as ProductId,
  key product_currency_code as ProductCurrencyCode,
  @Semantics.amount.currencyCode: 'ProductCurrencyCode'
  product_price as ProductPrice,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as LocalLastChangedAt,
  _Product
}
