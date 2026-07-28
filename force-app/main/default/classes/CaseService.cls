global class CaseService {
    public CaseService() {

    }
    global static void closeCases (Set<Id> caseIds, string reason) {
        // Validate parameters
        if(caseIds==null || caseIds.size()==0)
            throw new CaseServiceException('Case not specified.');
        if(reason == null)
            throw new CaseServiceException('Reason not specified.');  
            
        // Query Cases (SOQL inlined for this example, see Selector pattern in later module)
        List<Case> cases = [SELECT Reason 
             FROM Case WHERE Id IN :caseIds];           

        List<Case> casesToUpdate = new List<Case>();

        for(Case c : cases) {
            c.Reason = reason;
            c.Status = 'Closed';
            casesToUpdate.add(c);
        }

        // Update the database
        SavePoint sp = Database.setSavePoint();
        try {
            update casesToUpdate;
        } catch (Exception e) {
            // Rollback
            Database.rollback(sp);
            // Throw exception on to caller
            throw e;
        }

    }

    public class CaseServiceException extends Exception {}
}