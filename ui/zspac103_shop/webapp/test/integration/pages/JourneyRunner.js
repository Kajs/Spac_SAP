sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"zspac103_shop/test/integration/pages/ProductByCurrencyList.gen",
	"zspac103_shop/test/integration/pages/ProductByCurrencyObjectPage.gen"
], function (JourneyRunner, ProductByCurrencyListGenerated, ProductByCurrencyObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('zspac103_shop') + '/test/flp.html#app-preview',
        pages: {
			onTheProductByCurrencyListGenerated: ProductByCurrencyListGenerated,
			onTheProductByCurrencyObjectPageGenerated: ProductByCurrencyObjectPageGenerated
        },
        async: true
    });

    return runner;
});

