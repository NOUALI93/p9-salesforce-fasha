trigger UpdateAccountCA on Order (after update) {

    // Collecter les IDs des comptes concernés
    Set<Id> accountIds = new Set<Id>();
    for (Order newOrder : Trigger.new) {
        Order oldOrder = Trigger.oldMap.get(newOrder.Id);
        // On met à jour le CA uniquement quand le statut passe à 'Activated'
        if (newOrder.Status == 'Activated' && oldOrder.Status != 'Activated') {
            if (newOrder.AccountId != null) {
                accountIds.add(newOrder.AccountId);
            }
        }
    }

    if (accountIds.isEmpty()) return;

    // Récupérer les comptes en une seule requête SOQL (bulkifié)
    Map<Id, Account> accountMap = new Map<Id, Account>(
        [SELECT Id, ChiffreAffaire__c FROM Account WHERE Id IN :accountIds]
    );

    // Calculer le CA total des commandes Activated pour chaque compte
    List<AggregateResult> results = [
        SELECT AccountId, SUM(TotalAmount) total
        FROM Order
        WHERE AccountId IN :accountIds
        AND Status = 'Activated'
        GROUP BY AccountId
    ];

    for (AggregateResult ar : results) {
        Id accId = (Id) ar.get('AccountId');
        Decimal total = (Decimal) ar.get('total');
        if (accountMap.containsKey(accId)) {
            accountMap.get(accId).ChiffreAffaire__c = total;
        }
    }

    // Mettre à jour tous les comptes en une seule DML (bulkifié)
    update accountMap.values();
}