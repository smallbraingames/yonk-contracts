import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
    systems: {
        ClaimSystem: {
            openAccess: true
        },
        GetIdSystem: {
            openAccess: false,
            accessList: ["RegisterSystem", "YellSystem"]
        },
        RegisterSystem: {
            openAccess: true,
        },
        YellSystem: {
            openAccess: true,
        },
    },
    tables: {
        Id: {
            keySchema: {},
            valueSchema: {
                value: "uint64",
            },
        },
    },
});