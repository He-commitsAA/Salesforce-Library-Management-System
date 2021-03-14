({
    getProperties: function getProperties(component) {
        var action = component.get('c.getPagedBranchList');

        action.setParams({
            pageSize: 100,
            pageNumber: 1
        });
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS') {
                var pagedResults = response.getReturnValue();

                component.set('v.branches', pagedResults.records);
            } else {
                var toastEvent = $A.get('e.force:showToast');

                toastEvent.setParams({
                    title: 'Error',
                    message: 'Error retrieving branches.',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
});
