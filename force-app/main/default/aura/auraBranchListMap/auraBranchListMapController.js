({
    handleInit: function (component, event, helper) {
        helper.getBranches(component);
    },

    handleJSLoaded: function (component) {
        component.set('v.jsLoaded', true);
    }
});
