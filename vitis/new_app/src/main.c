#include "xgpiops.h"

#include "xll_fifo/fifo_platform.h"
#include "ad9361/ad9361_platform.h"


#define FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID
#define TEST_BUFFER_SIZE 32

static u8 SendBuffer[TEST_BUFFER_SIZE];	/* Buffer for Transmitting Data */
static u8 RecvBuffer[TEST_BUFFER_SIZE];	/* Buffer for Receiving Data */


/* FIFO driver instance */
XLlFifo FifoInstance;

int main(void){

	u32 mode;
	XGpioPs my_gpio;
	XGpioPs_Config *cfg_ptr;

	int Status;

	/* -------------- AD9361 init -------------- */
	ad9361Init(ad9361_phy);

	// xil_printf("Hello\n");
	
	cfg_ptr = XGpioPs_LookupConfig(XPAR_XGPIOPS_0_DEVICE_ID);
	XGpioPs_CfgInitialize(&my_gpio, cfg_ptr, cfg_ptr->BaseAddr);
	XGpioPs_SetDirectionPin(&my_gpio, 55, 1);
	XGpioPs_SetOutputEnablePin(&my_gpio, 55, 1);
	XGpioPs_SetDirectionPin(&my_gpio, 56, 1);
	XGpioPs_SetOutputEnablePin(&my_gpio, 56, 1);
	XGpioPs_WritePin(&my_gpio, 55,1);
	XGpioPs_WritePin(&my_gpio, 56,1);

	/* --------------------------------------- */

	xil_printf("--- Welcome to simple_sdr API ---\n\r");



	while(1)
	{
		/* Check ad9361 state machine status for debug */
		ad9361_get_en_state_machine_mode(ad9361_phy, &mode);
//		XUartPs_SetOperMode(&Uart_PS, XUARTPS_OPER_MODE_AUTO_ECHO);
//		for (Index = 0; Index < TEST_BUFFER_SIZE; Index++) {
//			SendBuffer[Index] = '0' + Index;
//			RecvBuffer[Index] = 0;
//		}

		/* Block sending the buffer. */
//		SentCount = XUartPs_Send(&Uart_PS, SendBuffer, TEST_BUFFER_SIZE);

		Status = FifoPolling(&FifoInstance, FIFO_DEV_ID);
		if (Status != XST_SUCCESS)
		{
			xil_printf(" Test Failed. Output data doesn't match input stream\n\r");
	//		xil_printf("--- Exiting API ---\n\r");
	//		return XST_FAILURE;
		}
//		xil_printf(" Test Succeeded. Output data matches input stream\n\r");
	//	xil_printf("--- Exiting API ---\n\r");
	//	return XST_SUCCESS;
	}
}

