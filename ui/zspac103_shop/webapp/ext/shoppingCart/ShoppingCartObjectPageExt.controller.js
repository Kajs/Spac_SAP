
sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    return ControllerExtension.extend(
        "zspac103_shop.ext.shoppingCart.ShoppingCartObjectPageExt",
        {
            backToShoppingCart: function () {
                return this.base.getExtensionAPI()
                    .getRouting()
                    .navigateToRoute("ShoppingCartCustomPage");
            }
        }
    );
});
