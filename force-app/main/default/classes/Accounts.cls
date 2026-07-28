public class Accounts extends fflib_SObjectDomain implements IAccounts {
    
    public Accounts(List<Account> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }

   public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> accountsWithChangedCountryIds = new Set<Id>();
        
        for (Account newAcc : (List<Account>) Records) {
            Account oldAcc = (Account) existingRecords.get(newAcc.Id);
            if (newAcc.ShippingCountry != oldAcc.ShippingCountry) {
                accountsWithChangedCountryIds.add(newAcc.Id);
            }
        }

        // Delegeer de daadwerkelijke actie naar de Service-laag
        if (!accountsWithChangedCountryIds.isEmpty()) {
            AccountsService.syncMailingCountryToContacts(accountsWithChangedCountryIds);
        }
    }
}
