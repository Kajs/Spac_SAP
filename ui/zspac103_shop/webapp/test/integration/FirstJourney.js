sap.ui.define([
    "sap/ui/test/opaQunit",
    "./pages/JourneyRunner"
], function (opaTest, runner) {
    "use strict";

    function journey() {
        QUnit.module("First journey");

        opaTest("Start application", function (Given, When, Then) {
            Given.iResetMockData({ ServiceUri: "/sap/opu/odata4/sap/zui_spac103_product_q_o4/srvd/sap/zui_spac103_product_q_sd/0001/" });
            Given.iResetTestData();
            Given.iStartMyApp();
            Then.onTheProductByCurrencyListGenerated.iSeeThisPage();
        });


        opaTest("Navigate to ObjectPage", function (Given, When, Then) {
            // Note: this test will fail if the ListReport page doesn't show any data
            
            When.onTheProductByCurrencyListGenerated.onFilterBar().iExecuteSearch();
            
            Then.onTheProductByCurrencyListGenerated.onTable().iCheckRows();

            When.onTheProductByCurrencyListGenerated.onTable().iPressRow(0);
            Then.onTheProductByCurrencyObjectPageGenerated.iSeeThisPage();

        });

        opaTest("Teardown", function (Given, When, Then) { 
            // Cleanup
            Given.iTearDownMyApp();
        });
    }

    runner.run([journey]);
});