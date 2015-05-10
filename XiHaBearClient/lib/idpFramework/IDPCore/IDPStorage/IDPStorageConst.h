//
//  IDPStorageConst.h
//  IDP
//
//  Created by douj on 17-3-12.
//
//

#ifndef IDP_IDPStorageConst_h
#define IDP_IDPStorageConst_h

typedef enum  {
    IDPStorageDisk,
    IDPStorageSql,
}IDPStorageType;

typedef enum  {
    IDPCacheStorageMemory,
    IDPCacheStorageDisk,
    IDPCacheStorageMemoryAndDisk
}IDPCacheStoragePolicy;

#endif
