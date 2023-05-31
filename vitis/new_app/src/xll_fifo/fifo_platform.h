#ifndef FIFO_PLATFORM_H	
#define FIFO_PLATFORM_H

#include "xil_exception.h"
#include "xstreamer.h"
#include "xil_cache.h"
#include "xllfifo.h"
#include "xstatus.h"

/* FIFO driver instance */
XLlFifo FifoInstance;

/* FIFO buffer definitions */
u32 SourceBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
u32 DestinationBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];

/* FIFO function prototypes */
int FifoPolling(XLlFifo *InstancePtr, u16 DeviceId);
int TxSend(XLlFifo *InstancePtr, u32 *SourceAddr);
int RxReceive(XLlFifo *InstancePtr, u32 *DestinationAddr);

#endif