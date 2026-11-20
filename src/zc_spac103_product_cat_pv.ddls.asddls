
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product catalog'
@Metadata.allowExtensions: true

define root view entity ZC_SPAC103_PRODUCT_CAT_PV
  provider contract transactional_query
  as projection on ZR_SPAC103_PRODUCT_DD_RWE
{
  key ProductId,
      ProductName,
      ProductDescription,
      @Semantics.imageUrl: true
      ProductImage,
      ImageMimeType,
      ImageFileName
}
