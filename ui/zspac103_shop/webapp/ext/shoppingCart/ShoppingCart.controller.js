
sap.ui.define([
    "sap/fe/core/PageController"
], function (PageController) {
    "use strict";

    return PageController.extend(
        "zspac103_shop.ext.shoppingCart.ShoppingCart",
        {
            onInit: function () {
                PageController.prototype.onInit.apply(this, arguments);

                this._hasOpenedShoppingCart = false;

                // Listen for navigation to the Shopping Cart overview
                const router = this.getAppComponent().getRouter();
                const route = router.getRoute("ShoppingCartCustomPage");

                if (route) {
                    route.attachPatternMatched(
                        this._onShoppingCartRouteMatched,
                        this
                    );
                }
            },

            _onShoppingCartRouteMatched: function () {

                // The initial load is already handled by initialLoad="true"
                if (!this._hasOpenedShoppingCart) {
                    this._hasOpenedShoppingCart = true;
                    return;
                }

                // Refresh the Shopping Cart table when returning to the overview
                const table = this.getExtensionAPI()
                    .byId("ShoppingCartTable");

                if (table && typeof table.refresh === "function") {
                    table.refresh();
                }
            },

            onBackToProductCatalog: function () {
                return this.getExtensionAPI()
                    .getRouting()
                    .navigateToRoute("ProductByCurrencyList");
            }
        }
    );
});
