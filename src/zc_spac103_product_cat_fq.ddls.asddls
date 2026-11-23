@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product catalog with currency filter'

define view entity ZC_SPAC103_PRODUCT_CAT_FQ
  as select from ZR_SPAC103_PRODUCT_DD_RWE as Product

    cross join ZI_SPAC103_CURRENCY_VH as Currency

    left outer join ZR_SPAC103_P_PRICE as Price
      on Price.ProductId = Product.ProductId
     and Price.ProductCurrencyCode = Currency.Currency

{
  key Product.ProductId as ProductId,
  @EndUserText.label: 'Display Currency'
  @Consumption.filter: {
    selectionType: #SINGLE,
    multipleSelections: false,
    mandatory: false
  }
  @Consumption.filter.defaultValue: 'DKK'
  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: 'ZI_SPAC103_CURRENCY_VH',
        element: 'Currency'
      }
    }
  ]
  @UI.selectionField: [{ position: 10 }]
  key Currency.Currency as ProductCurrencyCode,

      Product.ProductName as ProductName,
      Product.ProductDescription as ProductDescription,

      @Semantics.imageUrl: true
      Product.ProductImage as ProductImage,

      Product.ImageMimeType as ImageMimeType,
      Product.ImageFileName as ImageFileName,

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
