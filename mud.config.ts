import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    systems: {
        ClaimSystem: {
            name: "claim",
            openAccess: true
        },
        RegisterSystem: {
            name: "register",
            openAccess: true,
        },
        YellSystem: {
            name: "yell",
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