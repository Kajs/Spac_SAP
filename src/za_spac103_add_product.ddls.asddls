@EndUserText.label: 'Parameters for adding a product'

define abstract entity ZA_SPAC103_ADD_PRODUCT
{
  @EndUserText.label: 'Product'
  @Consumption.valueHelpDefinition: [
    {
      entity: {
        name: 'ZC_SPAC103_PRODUCT_CAT_PV',
        element: 'ProductId'
      },
      useForValidation: true
    }
  ]
  ProductId : abap.int4;

  @EndUserText.label: 'Quantity'
  Quantity  : abap.int4;
}
