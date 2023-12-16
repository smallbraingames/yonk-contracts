import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    systems: {
        YellSystem: {
            name: "yell",
            openAccess: true,
        },
        ClaimSystem: {
            name: "claim",
            openAccess: true
        }
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