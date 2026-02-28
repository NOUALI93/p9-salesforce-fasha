public without sharing class MyTeamOrdersController {

    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {
        if (accountId == null) return 0;

        AggregateResult groupedResults = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId
            AND Status = 'Activated'
        ];

        Decimal total = (Decimal) groupedResults.get('total');
        return total != null ? total : 0;
    }
}