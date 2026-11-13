@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view entity for _product'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_SPAC103_PRODUCT_DD_RWE as select from ZSPAC103_PRODUCT
composition [0..*] of ZR_SPAC103_P_PRICE as _Prices

{
  key product_id as ProductId,
  product_name as ProductName,
  product_description as ProductDescription,
  _Prices
}
