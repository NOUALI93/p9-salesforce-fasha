@isTest
private class testUpdateProductPrices {

    @isTest
    static void testBatchUpdatesPrices() {
        // Créer un produit de test
        PricebookEntry pbe = FashaTestDataFactory.createProduct('Chemise Test', 100);

        // Vérifier le prix initial
        PricebookEntry before = [SELECT UnitPrice FROM PricebookEntry WHERE Id = :pbe.Id];
        System.assertEquals(100, before.UnitPrice, 'Prix initial doit être 100');

        // Lancer le batch avec 10% d'augmentation
        Test.startTest();
        UpdateProductPrices batch = new UpdateProductPrices(10);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Vérifier que le prix a été mis à jour
        PricebookEntry after = [SELECT UnitPrice FROM PricebookEntry WHERE Id = :pbe.Id];
        System.assertEquals(110, after.UnitPrice, 'Prix doit être 110 après 10% augmentation');
    }

   @isTest
    static void testBatchDoesNotAffectActivatedOrders() {
        Account acc = FashaTestDataFactory.createAccount('Test Account Prix');
        PricebookEntry pbe = FashaTestDataFactory.createProduct('Produit Prix', 100);
        Order o = FashaTestDataFactory.createOrder(acc.Id, 'Draft');

        // Ajouter 3 lignes pour respecter la règle de validation
        FashaTestDataFactory.createOrderItem(o.Id, pbe.Id, 2, 100);
        FashaTestDataFactory.createOrderItem(o.Id, pbe.Id, 3, 100);
        FashaTestDataFactory.createOrderItem(o.Id, pbe.Id, 1, 100);

        // Mettre à jour ShipmentCost avant d'activer
        o.ShipmentCost__c = 0;
        update o;

        // Activer la commande
        o.Status = 'Activated';
        update o;

        // Récupérer le CA avant
        Account accBefore = [SELECT ChiffreAffaire__c FROM Account WHERE Id = :acc.Id];
        Decimal caBefore = accBefore.ChiffreAffaire__c;

        // Lancer le batch de mise à jour des prix
        Test.startTest();
        UpdateProductPrices batch = new UpdateProductPrices(50);
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Vérifier que le TotalAmount de la commande activée N'A PAS changé
        Order orderAfter = [SELECT TotalAmount FROM Order WHERE Id = :o.Id];
        System.assertEquals(600, orderAfter.TotalAmount,
            'Le TotalAmount de la commande activée ne doit pas changer');

        // Vérifier que le CA du compte N'A PAS changé
        Account accAfter = [SELECT ChiffreAffaire__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(caBefore, accAfter.ChiffreAffaire__c,
            'Le CA du compte ne doit pas changer suite à une MAJ des prix');
    }

    @isTest
    static void testScheduler() {
        Test.startTest();
        // Planifier chaque lundi à 8h
        String cronExp = '0 0 8 ? * MON *';
        UpdateProductPricesScheduler scheduler = new UpdateProductPricesScheduler(5);
        System.schedule('Test Weekly Price Update', cronExp, scheduler);
        Test.stopTest();

        // Vérifier que le job est schedulé
        List<CronTrigger> jobs = [
            SELECT Id, CronExpression, State 
            FROM CronTrigger 
            WHERE CronJobDetail.Name = 'Test Weekly Price Update'
        ];
        System.assertEquals(1, jobs.size(), 'Le job doit être schedulé');
    }
}