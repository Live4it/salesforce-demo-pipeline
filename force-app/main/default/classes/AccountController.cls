// AccountController.cls
public with sharing class AccountController {
    @AuraEnabled
    public static void processVipStatus(Id accountId) {
        try {
            AccountsService.updateVipStatus(new Set<Id>{ accountId });
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
