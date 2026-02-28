global class UpdateProductPrices implements Database.Batchable<sObject> {

    // Pourcentage de mise à jour du prix (ex: 5% d'augmentation)
    private Decimal priceUpdatePercentage;

    global UpdateProductPrices(Decimal percentage) {
        this.priceUpdatePercentage = percentage;
    }

    // Récupérer uniquement les fiches produits actives
    global Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(
            'SELECT Id, UnitPrice FROM PricebookEntry WHERE IsActive = true'
        );
    }

    global void execute(Database.BatchableContext info, List<PricebookEntry> scope) {
        List<PricebookEntry> toUpdate = new List<PricebookEntry>();

        for (PricebookEntry pbe : scope) {
            // Mettre à jour uniquement le prix du produit
            // JAMAIS le CA des commandes déjà activées
            Decimal newPrice = pbe.UnitPrice * (1 + priceUpdatePercentage / 100);
            toUpdate.add(new PricebookEntry(
                Id = pbe.Id,
                UnitPrice = newPrice.setScale(2)
            ));
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    global void finish(Database.BatchableContext info) {
        System.debug('UpdateProductPrices batch terminé avec succès.');
    }
}