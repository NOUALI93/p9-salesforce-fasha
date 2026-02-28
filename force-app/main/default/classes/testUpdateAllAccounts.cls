@isTest
private class testUpdateAllAccounts {

    @isTest
    static void testBatchUpdateCA() {
        Account acc1 = FashaTestDataFactory.createAccount('Test Account 1');
        PricebookEntry pbe = FashaTestDataFactory.createProduct('Chemise Verte', 1020);
        Order o1 = FashaTestDataFactory.createOrder(acc1.Id, 'Draft');
        FashaTestDataFactory.createOrderItem(o1.Id, pbe.Id, 10, 150);
        FashaTestDataFactory.createOrderItem(o1.Id, pbe.Id, 20, 1000);

        o1.Status = 'Activated';
        update o1;

        Test.startTest();
        UpdateAllAccounts batch = new UpdateAllAccounts();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        Account updatedAcc = [SELECT ChiffreAffaire__c FROM Account WHERE Id = :acc1.Id];
        System.assertNotEquals(null, updatedAcc.ChiffreAffaire__c, 'Le CA ne doit pas être null');
        System.assert(updatedAcc.ChiffreAffaire__c > 0, 'Le CA doit être supérieur à 0');
    }

    @isTest
    static void testBatchNoActivatedOrders() {
        Account acc2 = FashaTestDataFactory.createAccount('Test Account 2');

        Test.startTest();
        UpdateAllAccounts batch = new UpdateAllAccounts();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        Account updatedAcc = [SELECT ChiffreAffaire__c FROM Account WHERE Id = :acc2.Id];
        System.assertEquals(null, updatedAcc.ChiffreAffaire__c, 'Le CA doit être null sans commandes');
    }
    @isTest
    static void testCalculMontantAvecShipmentCost() {
        Account acc = FashaTestDataFactory.createAccount('Test Calcul');
        PricebookEntry pbe = FashaTestDataFactory.createProduct('Produit Test', 100);
        Order o = FashaTestDataFactory.createOrder(acc.Id, 'Draft');
        FashaTestDataFactory.createOrderItem(o.Id, pbe.Id, 2, 100);

        // Test avec ShipmentCost renseigné
        o.ShipmentCost__c = 20;
        update o;

        Order updated = [SELECT NetAmount__c FROM Order WHERE Id = :o.Id];
        System.assertNotEquals(null, updated.NetAmount__c, 'NetAmount ne doit pas être null');
    }

    @isTest
    static void testCalculMontantSansShipmentCost() {
        Account acc = FashaTestDataFactory.createAccount('Test Calcul Null');
        PricebookEntry pbe = FashaTestDataFactory.createProduct('Produit Test 2', 100);
        Order o = FashaTestDataFactory.createOrder(acc.Id, 'Draft');
        FashaTestDataFactory.createOrderItem(o.Id, pbe.Id, 2, 100);

        // Test sans ShipmentCost (null)
        o.ShipmentCost__c = null;
        update o;

        Order updated = [SELECT NetAmount__c FROM Order WHERE Id = :o.Id];
        System.assertEquals(0, updated.NetAmount__c, 'NetAmount doit être 0 si ShipmentCost est null');
    }
}