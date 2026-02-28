trigger CalculMontant on Order (before update) {

    // Boucle sur les commandes
    for (Order newOrder : Trigger.new) {
        if (newOrder.TotalAmount != null && newOrder.ShipmentCost__c != null) {
            newOrder.NetAmount__c = newOrder.TotalAmount - newOrder.ShipmentCost__c;
        } else {
            newOrder.NetAmount__c = 0;
        }
    }
}