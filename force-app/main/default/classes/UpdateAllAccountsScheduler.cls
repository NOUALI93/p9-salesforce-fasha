global class UpdateAllAccountsScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Lancer le batch chaque semaine
        UpdateAllAccounts batch = new UpdateAllAccounts();
        Database.executeBatch(batch, 200);
    }
}