/*************************************************************************
     ** File Name: HBHandler.h
    ** Author: fl570
    ** Mail: cqfl570@gmail.com
    ** Created Time: Wed Apr 10 16:46:51 2013
    **Copyright [2013] <Copyright fl570>  [legal/copyright]
 ************************************************************************/

#ifndef KINGSLANDING_ONLINEWHITEBOARD_SERVER_MONITOR_HBHANDLER_H_
#define KINGSLANDING_ONLINEWHITEBOARD_SERVER_MONITOR_HBHANDLER_H_

#define DBMANAGER Kingslanding::OnlineWhiteBoard::Server::DBManager

#include "../DBManager/DBManager.h"
#include "../message.pb.h"

namespace Kingslanding {
namespace OnlineWhiteBoard {
namespace server {
namespace Monitor {

class HbHandler {
public:
    HbHandler();
    HeartReturnPackage GetUserState(HeartBeatSendPackage&);
    ~HbHandler();
private:
    DBMANAGER::DBManager* db_manager_;
};
}  // Monitor
}  // server
}  // OnlineWhiteBoard
}  // Kingslanding
#endif  // KINGSLANDING_ONLINEWHITEBOARD_SERVER_MONITOR_HBHANDLER_H_
