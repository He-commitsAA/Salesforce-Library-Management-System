({
    handleInit: function (component, event, helper) {
        helper.getProperties(component);
    },

    handleJSLoaded: function (component) {
        component.set('v.jsLoaded', true);
    }
});
