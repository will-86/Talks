vnets = {
    "core"  = "10.21.0.0/16"
    "dev"   = "10.35.0.0/16"
    "uat"   = "10.98.0.0/16"
}

subnets = {
    "core" = {
        "Prod"  = "10.21.1.0/24"
        "Mgmt"  = "10.21.2.0/24"
        "DMZ"   = "10.21.3.0/24"
    }
    "dev" = {
        "Main"  = "10.35.1.0/24"
        "Mgmt"  = "10.35.2.0/24"
    }
    "uat" = {
        "Main"  = "10.98.1.0/24"
        "Mgmt"  = "10.98.2.0/24"
        "DMZ"   = "10.98.3.0/24"
    }
}