@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shopping cart item total price'

define view entity ZV_SPAC103_CITEM_TOTAL_PRICE
  as select from zspac103_citem
{
    key cart_uuid as CartUUID,
    key product_id as ProductId,

    product_name as ProductName,
    quantity as Quantity,
    currency_code as CurrencyCode,

    @Semantics.amount.currencyCode: 'CurrencyCode'
    unit_price as UnitPrice,

    @EndUserText.label: 'Line Total'
    @Semantics.amount.currencyCode: 'CurrencyCode'
    curr_to_decfloat_amount( unit_price )
        * quantity as LineTotal
}
