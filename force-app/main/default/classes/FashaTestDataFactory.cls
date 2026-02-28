@isTest
public class FashaTestDataFactory {

    public static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    public static PricebookEntry createProduct(String productName, Decimal price) {
        Product2 product = new Product2(
            Name = productName,
            Family = 'Vêtements',
            IsActive = true
        );
        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = price,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    public static Order createOrder(Id accountId, String status) {
        Order o = new Order(
            AccountId = accountId,
            Status = status,
            EffectiveDate = Date.today(),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert o;
        return o;
    }

    public static OrderItem createOrderItem(Id orderId, Id pricebookEntryId, Integer quantity, Decimal unitPrice) {
        OrderItem oi = new OrderItem(
            OrderId = orderId,
            PricebookEntryId = pricebookEntryId,
            Quantity = quantity,
            UnitPrice = unitPrice
        );
        insert oi;
        return oi;
    }

    public static List<Order> createMultipleOrders(Id accountId, Integer count, String status) {
        List<Order> orders = new List<Order>();
        for (Integer i = 0; i < count; i++) {
            orders.add(new Order(
                AccountId = accountId,
                Status = status,
                EffectiveDate = Date.today(),
                Pricebook2Id = Test.getStandardPricebookId()
            ));
        }
        insert orders;
        return orders;
    }
}