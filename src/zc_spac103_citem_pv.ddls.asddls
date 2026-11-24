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
      
      @Semantics.largeObject: {
        mimeType: 'ImageMimeType',
        fileName: 'ImageFileName',
        acceptableMimeTypes: ['image/png', 'image/jpeg'],
        contentDispositionPreference: #INLINE
      }
      @Semantics.imageUrl: true
      _Product.ProductImage as ProductImage,
      @Semantics.mimeType: true
      _Product.ImageMimeType as ImageMimeType,
      _Product.ImageFileName as ImageFileName,

      _Cart : redirected to parent ZC_SPAC103_CART_PV
}
