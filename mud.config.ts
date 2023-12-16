import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    systems: {
        ClaimSystem: {
            openAccess: true
        },
        RegisterSystem: {
            openAccess: true,
        },
        YellSystem: {
            openAccess: true,
        },
    },
    tables: {
        CounterTable: {
            keySchema: {},
            valueSchema: {
                value: "uint32",
            },
            storeArgument: true,
        },
    },
});