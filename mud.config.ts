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
        Registration: {
            keySchema: {id: "uint64"}, 
            valueSchema: {
                devicePublicKeyX: "uint256",
                devicePublicKeyY: "uint256",
                accountAddress: "address"
            },
        }
    },
});