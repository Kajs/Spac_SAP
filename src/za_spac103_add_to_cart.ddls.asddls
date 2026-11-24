@EndUserText.label: 'Parameters for adding to shopping cart'

define abstract entity ZA_SPAC103_ADD_TO_CART
{
  @EndUserText.label: 'Quantity'
  @Consumption.defaultValue: '1'
  Quantity : abap.int4;
}
