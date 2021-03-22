public with sharing class BranchController {

    @AuraEnabled(cacheable=true)
    public static List<Branch__c> getBranches() {

        List<Branch__c> branches = [
            SELECT
                Id,
                Name,
                Phone__c,
                Location__Latitude__s,
                Location__Longitude__s,
                Address__c
            FROM Branch__c
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
        return branches;
    }
}
