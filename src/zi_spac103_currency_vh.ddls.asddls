@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Available product currencies'
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_SPAC103_CURRENCY_VH
  as select from zspac103_p_price
{
  key product_currency_code as Currency
}
group by product_currency_code
