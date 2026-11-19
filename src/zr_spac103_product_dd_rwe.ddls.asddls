@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view entity for _product'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZR_SPAC103_PRODUCT_DD_RWE
  as select from zspac103_product
  composition [0..*] of ZR_SPAC103_P_PRICE as _Prices
{
key product_id as ProductId,
  product_name as ProductName,
  product_description as ProductDescription,
  
  @Semantics.largeObject: {
    mimeType: 'ImageMimeType',
    fileName: 'ImageFileName',
    acceptableMimeTypes: ['image/png', 'image/jpeg'],
    contentDispositionPreference: #INLINE
  }
  product_image as ProductImage, 
  @Semantics.mimeType: true
  image_mime_type as ImageMimeType,
  image_file_name as ImageFileName,
  
  @Semantics.user.createdBy: true
  localcreatedby as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  localcreatedat as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  locallastchangedby as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  lastchangedat as LastChangedAt,
  
  _Prices
}
