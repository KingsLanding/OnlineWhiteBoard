/*************************************************************************
     ** File Name: ServerDelegate.h
    ** Author: fl570
    ** Mail: cqfl570@gmail.com
    ** Created Time: Wed Apr 10 16:46:51 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/


#ifndef KINGSLANDING_ONLINEWHITEBOARD_SERVER_DATAPROVIDER_MEMORYCACHE_H_
#define KINGSLANDING_ONLINEWHITEBOARD_SERVER_DATAPROVIDER_MEMORYCACHE_H_

#define QUEUESIZE 128
#include "../message.pb.h"
#include "../common.h"

namespace Kingslanding {
namespace OnlineWhiteBoard {
namespace Server {
namespace DataProvider {

class MemoryCache {
public:
      explicit MemoryCache(int capacity = QUEUESIZE);
      ~MemoryCache();

public:
      int IsEmpty() const;
      int IsFull() const;
      int GetCount() const;
      bool AddOperation(const Operation& oper);
      bool SetState();
      Operation* GetOperationAfter(int operation_id);

private:
      bool AddOperationToSet(int set, const Operation& oper);
      Operation* GetOperationFromSet(int set, int operation_id);
      FORBIDDEN_EVIL_CONSTRUCTOR(MemoryCache);
  
      int capacity_;
      bool state_;
      int front_[2];
      int rear_[2];
      int size_[2];
      int front_id_[2];
      int rear_id_[2];
      int index_;
      Operation** operation_[2];

      
};
}  // DataProvider
}  // Server
}  // OnlineWhiteBoard
}  // Kingslanding
#endif  // KINGSLANDING_ONLINEWHITEBOARD_SERVER_DATAPROVIDER_MEMORYCACHE_H_
