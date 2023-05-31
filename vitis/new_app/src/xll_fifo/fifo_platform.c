#include "xil_exception.h"
#include "xstreamer.h"
#include "xil_cache.h"
#include "xllfifo.h"
#include "xstatus.h"

#include "fifo_platform.h"

/* FIFO defines */
#define FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID
#define WORD_SIZE 4
#define MAX_PACKET_LEN 1
#define NO_OF_PACKETS 3
#define MAX_DATA_BUFFER_SIZE NO_OF_PACKETS*MAX_PACKET_LEN

int FifoPolling(XLlFifo *InstancePtr, u16 DeviceId)
{
	XLlFifo_Config *Config;
	int Status;
	int i;
	int Error;
	Status = XST_SUCCESS;

	/* Initialize the Device Configuration Interface driver */
	Config = XLlFfio_LookupConfig(DeviceId);
	if (!Config) {
		xil_printf("No config found for %d\r\n", DeviceId);
		return XST_FAILURE;
	}

	/* Initialize FIFO */
	Status = XLlFifo_CfgInitialize(InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed\n\r");
		return Status;
	}

	/* Transmit the Data Stream */
	Status = TxSend(InstancePtr, SourceBuffer);
	if (Status != XST_SUCCESS){
		xil_printf("Transmission of data failed\n\r");
		return XST_FAILURE;
	}

	/* Receive the Data Stream */
	Status = RxReceive(InstancePtr, DestinationBuffer);
	if (Status != XST_SUCCESS){
		xil_printf("Receiving data failed");
		return XST_FAILURE;
	}

	Error = 0;
	xil_printf(" Comparing data ...\n\r");
	for( i=0 ; i<MAX_DATA_BUFFER_SIZE ; i++ ){
		if ( *(SourceBuffer + i) != *(DestinationBuffer + i) ){
			Error = 1;
			break;
		}
	}

	if (Error != 0){
		return XST_FAILURE;
	}

	return Status;
}


int TxSend(XLlFifo *InstancePtr, u32  *SourceAddr)
{
	char8 c;
	u32 temp;

	int i;
	int j;
	int k;
	xil_printf(" Transmitting Data ... \r\n");
	xil_printf(" Enter the 12 character message to be sent: ");
	/* Fill the transmit buffer with incremental pattern */
	for (i=0;i<MAX_DATA_BUFFER_SIZE;i++)
	{
		for (k=0; k<4; k++)
		{
			outbyte(c = inbyte());
			temp = ((c<<(k*8)) | temp );
		}
		*(SourceAddr + i) = temp;
	}

	for(i=0 ; i < NO_OF_PACKETS ; i++){
		/* Writing into the FIFO Transmit Port Buffer */
		for (j=0 ; j < MAX_PACKET_LEN ; j++){
			if( XLlFifo_iTxVacancy(InstancePtr) ){
				XLlFifo_TxPutWord(InstancePtr, *(SourceAddr+(i*MAX_PACKET_LEN)+j));
			}
		}
	}

	/* Start Transmission by writing transmission length into the TLR */
	XLlFifo_iTxSetLen(InstancePtr, (MAX_DATA_BUFFER_SIZE * WORD_SIZE));

	/* Check for Transmission completion */
	while( !(XLlFifo_IsTxDone(InstancePtr)) ) {}

	/* Transmission Complete */
	return XST_SUCCESS;
}


int RxReceive (XLlFifo *InstancePtr, u32* DestinationAddr)
{

	int i;
	int Status;
	u32 RxWord;
	static u32 ReceiveLength;

	xil_printf(" Receiving data ....\n\r");

	while(XLlFifo_iRxOccupancy(InstancePtr)) {
		/* Read Receive Length */
		ReceiveLength = (XLlFifo_iRxGetLen(InstancePtr))/WORD_SIZE;
		for (i=0; i < ReceiveLength; i++) {
			RxWord = XLlFifo_RxGetWord(InstancePtr);
			*(DestinationBuffer+i) = RxWord;
		}
	}

	Status = XLlFifo_IsRxDone(InstancePtr);
	if(Status != TRUE){
		xil_printf("Failing in receive complete ... \r\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
