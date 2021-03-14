public with sharing class BranchController {

    private static final Integer DEFAULT_PAGE_SIZE = 9;

    /**
     * Endpoint that retrieves a paged and filtered list of branches
     * @param pageSize Number of branches per page
     * @param pageNumber Page number
     * @return PagedResult object holding the paged and filtered list of branches
     */
    @AuraEnabled(cacheable=true)
    public static PagedResult getPagedBranchList(
        Integer pageSize,
        Integer pageNumber
    ) {
        // Normalize inputs
        Integer safePageSize = (pageSize == null
            ? DEFAULT_PAGE_SIZE
            : pageSize);
        Integer safePageNumber = (pageNumber == null ? 1 : pageNumber);

        Integer offset = (safePageNumber - 1) * safePageSize;

        PagedResult result = new PagedResult();
        result.pageSize = safePageSize;
        result.pageNumber = safePageNumber;
        result.totalItemCount = [
            SELECT COUNT()
            FROM Branch__c
        ];
        result.records = [
            SELECT
                Id,
                Name,
                Phone__c,
                Location__Latitude__s,
                Location__Longitude__s
            FROM Branch__c
            WITH SECURITY_ENFORCED
            ORDER BY Name
            LIMIT :safePageSize
            OFFSET :offset
        ];
        return result;
    }
}
