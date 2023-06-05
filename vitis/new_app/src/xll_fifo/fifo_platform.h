#ifndef FIFO_PLATFORM_H	
#define FIFO_PLATFORM_H

#include "xil_exception.h"
#include "xstreamer.h"
#include "xil_cache.h"
#include "xllfifo.h"
#include "xstatus.h"

/* FIFO defines */
#define FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID
#define WORD_SIZE 4
#define MAX_PACKET_LEN 1
#define NO_OF_PACKETS 3
#define MAX_DATA_BUFFER_SIZE NO_OF_PACKETS*MAX_PACKET_LEN

/* FIFO function prototypes */
int FifoPolling(XLlFifo *InstancePtr, u16 DeviceId);
int TxSend(XLlFifo *InstancePtr, u32 *SourceAddr);
int RxReceive(XLlFifo *InstancePtr, u32 *DestinationAddr);

#endif
