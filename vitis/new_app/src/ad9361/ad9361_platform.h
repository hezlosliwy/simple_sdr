#ifndef AD9361_PLATFORM_H	
#define AD9361_PLATFORM_H

#include "xgpiops.h"
#include "xparameters.h"
#include "ad9361_api.h"
#include "ad9361.h"
#include "xil_printf.h"

int ad9361Init(struct ad9361_rf_phy *ad9361_phy);

extern struct ad9361_rf_phy *ad9361_phy;

#endif
