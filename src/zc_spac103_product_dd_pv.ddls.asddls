@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for _PRODUCT_DD_RWE'
@Metadata.allowExtensions: true

define root view entity ZC_SPAC103_PRODUCT_DD_PV 
  provider contract transactional_query
  as projection on ZR_SPAC103_PRODUCT_DD_RWE
{
  key ProductId,
  ProductName,
  ProductDescription,
  /* Associations */
  _Prices : redirected to composition child ZC_SPAC103_P_PRICE_PV
}
