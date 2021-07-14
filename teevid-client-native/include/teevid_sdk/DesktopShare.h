//
// Created by ivan on 13.07.21.
//

#ifndef _DESKTOPSHARE_H_
#define _DESKTOPSHARE_H_

struct DesktopShareOptions
{
  int fps;
  int start_x = 0;
  int start_y = 0;
  int end_x = -1;
  int end_y = -1;
  std::string window_name;
};


#endif //_DESKTOPSHARE_H_
