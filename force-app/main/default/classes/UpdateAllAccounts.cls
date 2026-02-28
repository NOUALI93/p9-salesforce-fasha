global class UpdateAllAccounts implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(
            'SELECT Id FROM Account WHERE Id IN ' +
            '(SELECT AccountId FROM Order WHERE Status = \'Activated\')'
        );
    }

    global void execute(Database.BatchableContext info, List<Account> scope) {
        Set<Id> accountIds = (new Map<Id, SObject>(scope)).keySet();

        List<AggregateResult> results = [
            SELECT AccountId, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIds
            AND Status = 'Activated'
            GROUP BY AccountId
        ];

        List<Account> accountsToUpdate = new List<Account>();
        for (AggregateResult ar : results) {
            Id accId = (Id) ar.get('AccountId');
            Decimal total = (Decimal) ar.get('total');
            accountsToUpdate.add(new Account(
                Id = accId,
                Chiffre_Affaire__c = total
            ));
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }

    global void finish(Database.BatchableContext info) {
        System.debug('UpdateAllAccounts batch terminé avec succès.');
    }
}