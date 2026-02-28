global class UpdateProductPricesScheduler implements Schedulable {

    private Decimal priceUpdatePercentage;

    global UpdateProductPricesScheduler(Decimal percentage) {
        this.priceUpdatePercentage = percentage;
    }

    global void execute(SchedulableContext sc) {
        // Lancer le batch chaque semaine avec 5% d'augmentation
        UpdateProductPrices batch = new UpdateProductPrices(priceUpdatePercentage);
        Database.executeBatch(batch, 200);
    }
}