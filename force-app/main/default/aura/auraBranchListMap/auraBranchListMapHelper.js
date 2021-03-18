({
    getBranches: function getBranches(component) {
        var action = component.get('c.getBranches');

        action.setCallback(this, function (response) {
            var state = response.getState();

            //if successful, set branches to the results
            if (state === 'SUCCESS') {
                var branchRecords = response.getReturnValue();

                component.set('v.branches', branchRecords);
            } else {
                //if unsuccessful, show a toast
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
