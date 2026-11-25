
sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend(
        "zspac103_shop.ext.productCatalog.ProductByCurrencyListExt",
        {
            openShoppingCart: function () {
                return this.base.getExtensionAPI()
                    .getRouting()
                    .navigateToRoute("ShoppingCartCustomPage");
            }
        }
    );
});
