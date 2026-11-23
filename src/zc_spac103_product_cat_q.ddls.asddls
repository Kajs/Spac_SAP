@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product catalog with selected currency'
@Metadata.allowExtensions: true

@UI.selectionVariant: [
  {
    parameters: [
      {
        name: 'p_currency',
        value: 'DKK'
      }
    ]
  }
]

define view entity ZC_SPAC103_PRODUCT_CAT_Q
with parameters
  @EndUserText.label: 'Display Currency'
  @Consumption.defaultValue: 'DKK'
  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: 'ZI_SPAC103_CURRENCY_VH',
        element: 'Currency'
      }
    }
  ]
  p_currency : zspac103_currency

  as select from ZR_SPAC103_PRODUCT_DD_RWE as Product

    left outer join ZR_SPAC103_P_PRICE as Price
      on Price.ProductId = Product.ProductId
     and Price.ProductCurrencyCode = $parameters.p_currency

{
  key Product.ProductId as ProductId,

      Product.ProductName as ProductName,
      Product.ProductDescription as ProductDescription,

      @Semantics.imageUrl: true
      Product.ProductImage as ProductImage,

      Product.ImageMimeType as ImageMimeType,
      Product.ImageFileName as ImageFileName,

      $parameters.p_currency as ProductCurrencyCode,

      @Semantics.amount.currencyCode: 'ProductCurrencyCode'
      Price.ProductPrice as ProductPrice,

      @Semantics.nullValueIndicatorFor: 'ProductPrice'
      cast(
        case
          when Price.ProductId is null then 'X'
          else ' '
        end
        as abap_boolean preserving type
      ) as ProductPriceNullIndicator
}
