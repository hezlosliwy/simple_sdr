#include "xgpiops.h"

#include "xll_fifo/fifo_platform.h"
#include "ad9361/ad9361_platform.h"

#define UART_DEVICE_ID  XPAR_XUARTPS_0_DEVICE_ID
#define FIFO_DEV_ID	   	XPAR_AXI_FIFO_0_DEVICE_ID
#define TEST_BUFFER_SIZE 32

/* FIFO driver instance */
XLlFifo FifoInstance;

int main(void){

	u32 mode;
	XGpioPs my_gpio;
	XGpioPs_Config *cfg_ptr;

	int Status;

	/* ---------- AD9361 and UART init ---------- */
	Status = UartInit(UART_DEVICE_ID);
	if (Status != XST_SUCCESS){
		xil_printf("Uart init failed");
	}

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

	PsPrint("--- Welcome to simple_sdr API ---\n\r");
	Fifoinit(&FifoInstance, FIFO_DEV_ID);
	while(1)
	{
		/* Check ad9361 state machine status for debug */
		ad9361_get_en_state_machine_mode(ad9361_phy, &mode);

		Status = FifoPolling(&FifoInstance, FIFO_DEV_ID);
		if (Status != XST_SUCCESS)
		{
			PsPrint(" Test Failed. Output data doesn't match input stream\n\r");
		}
		else{
			PsPrint(" Test Succeeded. Output data matches input stream\n\r");
		}
	}
}

