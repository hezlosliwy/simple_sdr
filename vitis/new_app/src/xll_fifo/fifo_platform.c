#include "xil_exception.h"
#include "xstreamer.h"
#include "xil_cache.h"
#include "xllfifo.h"
#include "xstatus.h"
#include "xuartps.h"
#include "xparameters.h"
#include "fifo_platform.h"
#include "xuartps.h"

/* FIFO buffer definitions */
u32 SourceBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];
u32 DestinationBuffer[MAX_DATA_BUFFER_SIZE * WORD_SIZE];

XUartPs Uart_PS;
XUartPs_Config *UartConfig;

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
		PsPrint("No config found\r\n");
		return XST_FAILURE;
	}

	/* Initialize FIFO */
	Status = XLlFifo_CfgInitialize(InstancePtr, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		PsPrint("Initialization failed\n\r");
		return Status;
	}

	/* Transmit the Data Stream */
	Status = TxSend(InstancePtr, SourceBuffer);
	if (Status != XST_SUCCESS){
		PsPrint("Transmission of data failed\n\r");
		return XST_FAILURE;
	}

	/* Receive the Data Stream */
	Status = RxReceive(InstancePtr, DestinationBuffer);
	if (Status != XST_SUCCESS){
		PsPrint("Receiving data failed\n\r");
		return XST_FAILURE;
	}

	Error = 0;
	PsPrint(" Comparing data ...\n\r");
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
	u8 c[1];
	u32 temp;
	int i;
	int j;
	int k;

	PsPrint(" Enter the 12 character message to be sent: ");
	
	for (i=0; i<MAX_DATA_BUFFER_SIZE; i++)
	{
		temp = 0;
		for (k=0; k<4; k++)
		{
			/* Reading and Writing from/to PS UART */
			c[0] = XUartPs_RecvByte(UartConfig->BaseAddress);
			PsPrint(c);
			/* Sending data in 32 bit packages */
			temp = ((c[0]<<(8*(3-k))) | temp );
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


int RxReceive(XLlFifo *InstancePtr, u32* DestinationAddr)
{

	int i;
	int Status;
	u32 RxWord;
	static u32 ReceiveLength;

	PsPrint(" Receiving data ...\n\r");

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
		PsPrint(" Failing in receive ... \r\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


int UartInit(u16 DeviceId)
{
	int Status;

	UartConfig = XUartPs_LookupConfig(DeviceId);
	if (NULL == UartConfig) {
		return XST_FAILURE;
	}
	Status = XUartPs_CfgInitialize(&Uart_PS, UartConfig, UartConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XUartPs_SetBaudRate(&Uart_PS, 115200);
	XUartPs_SetOperMode(&Uart_PS, XUARTPS_OPER_MODE_NORMAL);

	return XST_SUCCESS;
}


int PsPrint(u8 InputBuffer[])
{
	int Count = 0;

	/* Single character printout */
	if (InputBuffer[1] == '\r') 
		InputBuffer[1] = '\0';

	while (InputBuffer[Count] != '\0') {
		Count += XUartPs_Send(&Uart_PS, &InputBuffer[Count], 1);
	}

	return Count;
}
