@EndUserText.label: 'Parameters for adding a product'

define abstract entity ZA_SPAC103_ADD_PRODUCT
{
  @EndUserText.label: 'Product ID'
  ProductId : abap.int4;

  @EndUserText.label: 'Quantity'
  Quantity  : abap.int4;
}
