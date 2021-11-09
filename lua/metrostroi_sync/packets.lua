Metrostroi.SyncSystem = Metrostroi.SyncSystem or {}

Metrostroi.SyncSystem.Packets = {
    SPAWN_TRAIN       = 1,
    UPDATE_TRAIN      = 2,
    DELETE_TRAIN      = 3,

    SWITCH            = 4,
    ROUTE             = 5,
    CHAT              = 6,

    SYNC_SWITCHES     = 7,
    CHANGE_TPS        = 8,
    
    CONNECT           = 100,
    DISCONNECT        = 101,

    WRONG_PASSWORD    = 102,
    MAP_NOT_MATCH     = 103,
    ERROR_WHEN_CONN   = 104,
    PROTOCOL_MISMATCH = 105,
    SERVER_FULL       = 106,
}