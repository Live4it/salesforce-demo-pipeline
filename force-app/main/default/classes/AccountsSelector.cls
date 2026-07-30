public class AccountsSelector extends fflib_SObjectSelector implements IAccountsSelector {
    
    public static IAccountsSelector newInstance() {
        return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.ShippingCountry
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    // Specifieke methode voor onze User Story om accounts inclusief contacten op te halen
    public List<Account> selectByIdWithContacts(Set<Id> accountIds) {
        // 1. Start de basis query voor Account
        fflib_QueryFactory accountQueryFactory = newQueryFactory();
        
        // 2. Start de subquery context voor de child-relatie 'Contacts'
        // Dit lost de signature/void fout op!
        fflib_QueryFactory contactQueryFactory = accountQueryFactory.subselectQuery('Contacts');
        
        // 3. Voeg de specifieke Contact-velden toe aan de zojuist gemaakte subquery
        contactQueryFactory.selectFields(new List<Schema.SObjectField>{
            Contact.Id,
            Contact.MailingCountry,
            Contact.AccountId
        });
        
        // 4. Filter op de specifieke Account Ids en voer de query uit
        return (List<Account>) Database.query(
            accountQueryFactory.setCondition('Id IN :accountIds').toSOQL()
        );
    }
}